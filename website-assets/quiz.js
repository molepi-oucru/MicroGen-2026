function checkMCQ(id, correctValue, explanation) {
    const box = document.getElementById(id);
    const selected = box.querySelector('input[type="radio"]:checked');
    const feedback = box.querySelector('.feedback');
    if (!selected) {
        feedback.className = 'feedback incorrect';
        feedback.style.display = 'block';
        feedback.innerHTML = 'Please choose one answer before checking.';
        return;
    }
    if (selected.value === correctValue) {
        feedback.className = 'feedback correct';
        feedback.innerHTML = '<strong>Good choice.</strong> ' + explanation;
    } else {
        feedback.className = 'feedback incorrect';
        feedback.innerHTML = '<strong>Not the best answer.</strong> ' + explanation;
    }
    feedback.style.display = 'block';
}

function checkMCQDetailed(id, correctValue) {
    const box = document.getElementById(id);
    const selected = box.querySelector('input[type="radio"]:checked');
    const feedback = box.querySelector('.feedback');
    if (!selected) {
        feedback.className = 'feedback incorrect';
        feedback.style.display = 'block';
        feedback.innerHTML = 'Please choose one answer before checking.';
        return;
    }
    const isCorrect = selected.value === correctValue;
    feedback.className = isCorrect ? 'feedback correct' : 'feedback incorrect';
    feedback.innerHTML = mcqFeedback[id][selected.value];
    feedback.style.display = 'block';
    updateGlobalScore();
}

function resetMCQ(id) {
    const box = document.getElementById(id);
    box.querySelectorAll('input[type="radio"]').forEach(el => el.checked = false);
    const feedback = box.querySelector('.feedback');
    feedback.style.display = 'none';
    feedback.innerHTML = '';
    updateGlobalScore();
}

function submitQuiz() {
    const mcqs = document.querySelectorAll('.mcq');
    let correctCount = 0;
    let attemptedCount = 0;
    const totalCount = mcqs.length;

    mcqs.forEach(box => {
        const id = box.id;
        const correctValue = box.dataset.correct;
        const selected = box.querySelector('input[type="radio"]:checked');
        const feedback = box.querySelector('.feedback');

        if (selected) {
            attemptedCount++;
            const isCorrect = selected.value === correctValue;
            if (isCorrect) correctCount++;

            feedback.className = isCorrect ? 'feedback correct' : 'feedback incorrect';
            feedback.innerHTML = mcqFeedback[id][selected.value];
            feedback.style.display = 'block';
        } else {
            feedback.className = 'feedback incorrect';
            feedback.innerHTML = 'Please choose an answer before submitting.';
            feedback.style.display = 'block';
        }
    });

    const display = document.getElementById('mcq-total-score-display');
    if (display) {
        const percentage = (correctCount / totalCount) * 100;
        const scoreClass = percentage < 80 ? 'score-board score-low' : 'score-board';

        display.innerHTML = `
            <div class="${scoreClass}">
                <div class="score-status">Quiz Score: ${correctCount} / ${totalCount} correct (${Math.round(percentage)}%)</div>
                <div class="score-progress">Finished: ${attemptedCount} out of ${totalCount} questions answered.</div>
            </div>
        `;
        display.style.display = 'block';
        display.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

function resetQuiz() {
    const mcqs = document.querySelectorAll('.mcq');
    mcqs.forEach(box => {
        box.querySelectorAll('input[type="radio"]').forEach(el => el.checked = false);
        const feedback = box.querySelector('.feedback');
        feedback.style.display = 'none';
        feedback.innerHTML = '';
    });

    const display = document.getElementById('mcq-total-score-display');
    if (display) {
        display.style.display = 'none';
    }
}

function revealProtectedSource(button) {
    const box = button.closest('.protected-reveal');
    const content = box.querySelector('.protected-reveal-content');
    const armed = button.dataset.armed === 'true';
    if (!armed) {
        button.dataset.armed = 'true';
        button.textContent = 'Reveal source on second click';
        return;
    }
    const bytes = Uint8Array.from(atob(box.dataset.payload), char => char.charCodeAt(0));
    content.innerHTML = new TextDecoder().decode(bytes);
    content.style.display = 'block';
    button.style.display = 'none';
}

window.addEventListener('load', () => {
    const display = document.getElementById('mcq-total-score-display');
    if (display) display.style.display = 'none';
});