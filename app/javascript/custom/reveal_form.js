document.addEventListener('turbo:load', async function () {
    const revealBtn = document.querySelector('#new-wallet-form h2');

    revealBtn.addEventListener('click', function () {
            const form = document.querySelector('#new-wallet-form form')
            if(form.classList.contains('d-none')) {
                form.classList.remove('d-none')
                form.classList.add('d-block')
            }else {
                form.classList.add('d-none')
                form.classList.remove('d-block')
            }
        }
    );

});