document.addEventListener('turbo:load', async function() {
    console.log('turbo:load event fired');
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    let accounts = await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner()

    const withholdSingleTransaction = async (transaction) => {
        const value = transaction.value;
        const to = transaction.to;

        const _transaction = {
            to: to,
            value: value
        };

        const tx = await signer.sendTransaction(_transaction);
        console.log(tx);

        await tx.wait();

        console.log(`Transaction ${tx.hash} complete`);
    };

    document.querySelectorAll('.pending-transactions button').forEach((button) => {
        button.addEventListener('click', async (event) => {
            const to = event.target.dataset.to;
            const value = ethers.BigNumber.from(event.target.dataset.value);
            const _transaction = {
                to: to,
                value: value
            };
            console.log(_transaction);
            withholdSingleTransaction(_transaction);

        });
    });
});