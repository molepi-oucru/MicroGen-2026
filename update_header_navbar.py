import os
import re

def main():
    navbar_path = "/data/MicroGen-2026/_site/navbar.html"
    with open(navbar_path, "r", encoding="utf-8") as f:
        navbar = f.read()

    # directory = "/data/MicroGen-2026/_site/day-0/instructions/"
    directory = "/data/MicroGen-2026/_site/day-0/instructions/"
    count = 0

    for file in os.listdir(directory):
        if file.startswith("setup") and file.endswith(".html"):
            path = os.path.join(directory, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            
            # Replace the entire <header id="quarto-header">...</header> block
            new_content = re.sub(r'<header id="quarto-header".*?</header>', navbar, content, flags=re.DOTALL)
            
            with open(path, "w", encoding="utf-8") as f:
                f.write(new_content)
            
            count += 1

    print(f"Replaced {count} files.")

if __name__ == "__main__":
    main()
