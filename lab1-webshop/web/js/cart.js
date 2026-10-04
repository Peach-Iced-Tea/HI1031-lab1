const cartPanel = document.getElementById("cart-panel");
const openCartButton = document.getElementById("open-cart");
const closeCartButton = document.getElementById("close-cart");

function openCart() {
    if (!cartPanel.open) {
        cartPanel.showModal();
    }
}

openCartButton.addEventListener("click", openCart);

closeCartButton.addEventListener("click", () => {
    cartPanel.close();
});

// Return keyboard focus to the cart button after closing.
cartPanel.addEventListener("close", () => {
    openCartButton.focus();
});

// Reopen after a cart operation redirects back to this page.
const parameters = new URLSearchParams(window.location.search);

if (parameters.get("cart") === "open") {
    openCart();
}