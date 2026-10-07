package se.kth.webshop.dto;

import java.util.List;

/** Immutable snapshot for the presentation layer; contains no domain objects. */
public final class CartDTO {
    private final List<CartItemDTO> items;
    private final int itemCount;
    private final long total;

    public CartDTO(List<CartItemDTO> items, int itemCount, long total) {
        this.items = List.copyOf(items);
        this.itemCount = itemCount;
        this.total = total;
    }

    public List<CartItemDTO> getItems() {
        return items;
    }

    public int getItemCount() {
        return itemCount;
    }

    public long getTotal() {
        return total;
    }
}
