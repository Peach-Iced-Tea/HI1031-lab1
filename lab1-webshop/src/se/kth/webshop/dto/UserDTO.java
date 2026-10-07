package se.kth.webshop.dto;

/** Immutable snapshot for the presentation layer; contains no domain objects. */
public final class UserDTO {
    private final int id;
    private final String username;

    public UserDTO(int id, String username) {
        this.id = id;
        this.username = username;
    }

    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }
}
