package se.kth.webshop.service;

import java.util.ArrayList;
import java.util.List;
import se.kth.webshop.dao.ProductDao;
import se.kth.webshop.dao.UserDao;
import se.kth.webshop.dto.CartDTO;
import se.kth.webshop.dto.CartItemDTO;
import se.kth.webshop.dto.ProductDTO;
import se.kth.webshop.dto.UserDTO;
import se.kth.webshop.model.Product;
import se.kth.webshop.model.User;
import se.kth.webshop.security.Passwords;

/** Run with assertions enabled; fake DAOs avoid requiring a database. */
public class DtoBoundaryTest {
    public static void main(String[] args) {
        Product product = new Product(7, "Coffee", "Beans", 120);
        List<Product> source = new ArrayList<>(List.of(product));
        ProductDao products = new ProductDao() {
            @Override public List<Product> findAll() { return source; }
            @Override public Product findById(int id) {
                return id == 7 ? product : null;
            }
        };
        List<ProductDTO> result = new ProductService(products).getProducts();
        assert result.get(0).getId() == 7;
        assert result.get(0).getName().equals("Coffee");
        assert result.get(0).getDescription().equals("Beans");
        assert result.get(0).getPrice() == 120;
        source.clear();
        assert result.size() == 1 : "DAO list changes must not change DTO list";
        expectImmutable(() -> result.clear());

        CartService cart = new CartService(products);
        cart.add(7, 2);
        CartDTO before = cart.getSnapshot();
        cart.update(7, 3);
        CartDTO after = cart.getSnapshot();
        assert before.getItems().get(0).getQuantity() == 2;
        assert before.getItemCount() == 2 && before.getTotal() == 240;
        assert after.getItemCount() == 3 && after.getTotal() == 360;
        assert after.getItems().get(0).getProductId() == 7;
        assert after.getItems().get(0).getName().equals("Coffee");
        assert after.getItems().get(0).getPrice() == 120;
        assert after.getItems().get(0).getSubtotal() == 360;
        expectImmutable(() -> before.getItems().clear());
        cart.remove(7);
        assert cart.getSnapshot().getItems().isEmpty();
        assert after.getItems().size() == 1 : "Removing an item must not change old snapshots";
        assert new CartService(products).getSnapshot().getItemCount() == 0;
        try { cart.add(7, 100); throw new AssertionError("Invalid quantity accepted"); }
        catch (IllegalArgumentException expected) { }
        try { cart.add(999, 1); throw new AssertionError("Unknown product accepted"); }
        catch (IllegalArgumentException expected) { }

        List<CartItemDTO> mutable = new ArrayList<>(before.getItems());
        CartDTO copy = new CartDTO(mutable, 2, 240);
        mutable.clear();
        assert copy.getItems().size() == 1 : "CartDTO must defensively copy its list";

        String password = "a test password long enough";
        String hash = Passwords.hash(password.toCharArray());
        UserDao users = new UserDao() {
            @Override public User findByUsername(String name) {
                return name.equals("customer") ? new User(8, name, hash) : null;
            }
            @Override public User create(String name, String storedHash) {
                assert Passwords.verify(password.toCharArray(), storedHash);
                return new User(9, name, storedHash);
            }
        };
        AuthService auth = new AuthService(users);
        UserDTO user = auth.authenticate("customer", password);
        assert user.getId() == 8 && user.getUsername().equals("customer");
        assert auth.authenticate("customer", "wrong") == null;
        assert auth.authenticate("unknown", password) == null;
        UserDTO registered = auth.register("new_customer", password, password);
        assert registered.getId() == 9;
        assert registered.getUsername().equals("new_customer");
        for (var method : UserDTO.class.getMethods()) {
            assert !method.getName().toLowerCase().contains("password")
                    : "UserDTO must not expose credentials";
        }
        System.out.println("DTO boundary checks passed: products, authentication, cart snapshots and validation.");
    }

    private static void expectImmutable(Runnable change) {
        try { change.run(); throw new AssertionError("Snapshot collection is mutable"); }
        catch (UnsupportedOperationException expected) { }
    }
}
