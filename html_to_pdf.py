import os
import sys
import argparse
from bs4 import BeautifulSoup

# Try to import weasyprint
try:
    from weasyprint import HTML
except ImportError:
    print("Error: WeasyPrint not found. Please run this script in an environment where 'weasyprint' is installed.")
    sys.exit(1)

SITE_ROOT = "/data/MicroGen-2026/_site"

def process_html_file(rel_path, is_day_4=False, margin_css=""):
    abs_path = os.path.join(SITE_ROOT, rel_path)
    if not os.path.exists(abs_path):
        print(f"Warning: {abs_path} not found. Skipping.")
        return None

    with open(abs_path, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')

    # Remove UI elements
    to_remove = [
        'header#quarto-header',
        'nav#quarto-sidebar',
        'div#quarto-margin-sidebar',
        'div#quarto-search-results',
        '.quarto-navigation-tool',
        '#quarto-embedded-source-code-modal',
        'nav.quarto-page-breadcrumbs',
        'footer.footer',
        '.code-copy-button',
        '#quarto-back-to-top'
    ]
    for selector in to_remove:
        for el in soup.select(selector):
            el.decompose()

    # Expand all collapsed fields
    for el in soup.select('.collapse'):
        if 'show' not in el.get('class', []):
            el['class'] = el.get('class', []) + ['show']
    

    for el in soup.select('.collapsed'):
        classes = el.get('class', [])
        if 'collapsed' in classes:
            classes.remove('collapsed')
            el['class'] = classes
            
    for el in soup.find_all(attrs={"aria-expanded": "false"}):
        el['aria-expanded'] = 'true'

    for details in soup.find_all('details'):
        cl = details.get('class', [])
        is_code_fold = 'code-fold' in cl
        if is_day_4 and is_code_fold:
            for element in details.find_all('div'): 
                element.decompose() 
        # else:
            # details['open'] = ''


    # Fix relative paths for images and links to make them absolute
    parent_dir = os.path.dirname(abs_path)
    for img in soup.find_all('img'):
        src = img.get('src')
        if src and not src.startswith(('http', '/')):
            img['src'] = "file://" + os.path.normpath(os.path.join(parent_dir, src))

    for link in soup.find_all('link', rel='stylesheet'):
        href = link.get('href')
        if href and not href.startswith(('http', '/')):
            link['href'] = "file://" + os.path.normpath(os.path.join(parent_dir, href))

    # Add the PDF-specific CSS including margins and footer
    pdf_style = soup.new_tag('style')
    pdf_style.string = f"""
    {margin_css}
    body {{
        margin: 0 !important;
        padding: 0 !important;
    }}
    #quarto-content {{
        margin-top: 0 !important;
        display: block !important;
    }}
    main.content {{
        max-width: 100% !important;
        margin: 0 !important;
    }}
    code:not(pre code) {{
        white-space: nowrap !important;
    }}
    """
    # pdf_style.string = f"""
    # {margin_css}
    # body {{
    #     margin: 0 !important;
    #     padding: 0 !important;
    # }}
    # * {{
    #     color: black !important;
    # }}
    # #quarto-content {{
    #     margin-top: 0 !important;
    #     display: block !important;
    # }}
    # main.content {{
    #     max-width: 100% !important;
    #     margin: 0 !important;
    # }}
    # code:not(pre code) {{
    #     white-space: nowrap !important;
    # }}
    # """
    if soup.head:
        soup.head.append(pdf_style)
    else:
        new_head = soup.new_tag('head')
        new_head.append(pdf_style)
        soup.insert(0, new_head)

    return str(soup)

def main():
    parser = argparse.ArgumentParser(description="Convert Quarto HTML guides to PDF using WeasyPrint library.")
    parser.add_argument("input", help="Path to a single HTML file or a text file containing a list of HTML files.")
    parser.add_argument("-o", "--output", help="Output PDF file name.", default="output.pdf")
    parser.add_argument("--margin", help="General PDF page margin.", default="2cm")
    parser.add_argument("--margin-top", help="Top margin.")
    parser.add_argument("--margin-bottom", help="Bottom margin.")
    parser.add_argument("--margin-left", help="Left margin.")
    parser.add_argument("--margin-right", help="Right margin.")
    
    args = parser.parse_args()
    
    # Resolve margins
    m_top = args.margin_top if args.margin_top else args.margin
    m_bottom = args.margin_bottom if args.margin_bottom else args.margin
    m_left = args.margin_left if args.margin_left else args.margin
    m_right = args.margin_right if args.margin_right else args.margin
    
    # margin_css = f"""
    # @page {{
    #     size: A4;
    #     margin-top: {m_top};
    #     margin-right: {m_right};
    #     margin-bottom: {m_bottom};
    #     margin-left: {m_left};
    #     @bottom-right {{
    #         content: "Page " counter(page);
    #         font-family: sans-serif;
    #         font-size: 9pt;
    #         color: #666;
    #     }}
    # }}
    # """
    margin_css = f"""
    @page {{
        size: A4;
        margin-top: {m_top};
        margin-right: {m_right};
        margin-bottom: {m_bottom};
        margin-left: {m_left};
    }}
    """
    
    files_to_process = []
    if args.input.endswith('.html'):
        files_to_process = [args.input]
    else:
        with open(args.input, 'r') as f:
            files_to_process = [line.strip() for line in f if line.strip()]

    print(f"Preparing to process {len(files_to_process)} file(s)...")

    documents = []
    for rel_path in files_to_process:
        print(f"  Processing {rel_path}...")
        is_day_4 = "day-4" in rel_path
        html_content = process_html_file(rel_path, is_day_4, margin_css)
        if html_content:
            # Render each HTML to a Document object independently
            doc = HTML(string=html_content, base_url=SITE_ROOT).render()
            documents.append(doc)

    if not documents:
        print("No documents were successfully processed.")
        return

    print(f"Merging {len(documents)} documents and generating PDF: {args.output}...")
    
    all_pages = []
    for doc in documents:
        all_pages.extend(doc.pages)
    
    try:
        # Use the first document to write the combined pages
        documents[0].copy(all_pages).write_pdf(args.output)
        print(f"Success! PDF generated at: {args.output}")
    except Exception as e:
        import traceback
        print(f"Error during PDF generation: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    main()
