(() => {
    'use strict';
    const search = document.getElementById('opportunitySearch'); if (!search) return;
    const work = document.getElementById('opportunityWork'), status = document.getElementById('opportunityStatus'), applied = document.getElementById('opportunityApplied');
    const cards = [...document.querySelectorAll('.sd-opportunity')];
    [...new Set(cards.map(c => c.dataset.work).filter(Boolean))].sort().forEach(value => { const option = document.createElement('option'); option.value = value; option.textContent = value; work.append(option); });
    function filter() {
        const words = search.value.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean); let count = 0;
        cards.forEach(card => {
            const text = (card.textContent + ' ' + card.dataset.specialization).toLocaleLowerCase();
            const show = words.every(word => text.includes(word)) && (!work.value || card.dataset.work === work.value) && (!status.value || card.dataset.status === status.value) && (!applied.value || card.dataset.applied === applied.value);
            card.hidden = !show; if (show) count++;
        });
        document.getElementById('opportunityCount').textContent = count + ' ' + (count === 1 ? 'opportunity' : 'opportunities') + ' found';
        document.getElementById('opportunityNoMatches').hidden = count !== 0 || cards.length === 0;
    }
    document.getElementById('opportunityReset')?.addEventListener('click', () => { search.value = ''; work.value = ''; status.value = ''; applied.value = ''; filter(); search.focus(); });
    search.addEventListener('input', filter);[work, status, applied].forEach(control => control.addEventListener('change', filter)); filter();
})();
