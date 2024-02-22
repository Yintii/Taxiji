document.addEventListener('turbo:load', async function () {
    const slider = document.getElementById('withhold-percentage');
    const output = document.getElementById('withhold-percentage-value');
    if(slider && output){
        output.innerHTML = slider.value;
        slider.oninput = function () {
            output.innerHTML = this.value;
        }
    }
});