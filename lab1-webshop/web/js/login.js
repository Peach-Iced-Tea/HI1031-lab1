(() => {
    const modal = document.getElementById("login-modal");

    if (!modal) {
        return;
    }

    const closeButton = document.getElementById("close-login");
    const triggers = document.querySelectorAll("[data-login-trigger]");
    let lastTrigger = null;

    function openLogin() {
        // Avoid stacking the login modal over the cart dialog.
        const cartPanel = document.getElementById("cart-panel");

        if (cartPanel?.open) {
            cartPanel.close();
        }

        if (!modal.open) {
            modal.showModal();
        }
    }

    triggers.forEach((trigger) => {
        trigger.setAttribute("aria-haspopup", "dialog");
        trigger.setAttribute("aria-controls", "login-modal");

        trigger.addEventListener("click", (event) => {
            // Preserve opening the link in a new tab.
            if (event.ctrlKey || event.metaKey ||
                event.shiftKey || event.altKey) {
                return;
            }

            event.preventDefault();
            lastTrigger = trigger;
            openLogin();
        });
    });

    closeButton.addEventListener("click", () => {
        modal.close();
    });

    modal.addEventListener("close", () => {
        // Don't retain a typed password after dismissing the popup.
        modal.querySelector('input[name="password"]').value = "";

        const url = new URL(window.location.href);

        if (url.searchParams.get("login") === "open") {
            url.searchParams.delete("login");
            url.searchParams.delete("loginError");
            url.searchParams.delete("next");
            window.history.replaceState(null, "", url);
        }

        if (lastTrigger) {
            lastTrigger.focus();
        }
    });

    const parameters = new URLSearchParams(window.location.search);

    if (parameters.get("login") === "open") {
        lastTrigger = triggers[0] ?? null;
        openLogin();
    }
})();