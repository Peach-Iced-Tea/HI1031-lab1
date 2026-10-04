package se.kth.webshop.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import se.kth.webshop.model.Product;

public class ProductDao {

    public List<Product> findAll() throws SQLException {
        String sql = """
            SELECT id, name, description, price
            FROM products
            ORDER BY id
            """;

        List<Product> products = new ArrayList<>();

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet results = statement.executeQuery()) {

            while (results.next()) {
                products.add(new Product(
                    results.getInt("id"),
                    results.getString("name"),
                    results.getString("description"),
                    results.getInt("price")
                ));
            }
        }

        return products;
    }

    public Product findById(int id) throws SQLException {
        String sql = """
            SELECT id, name, description, price
            FROM products
            WHERE id = ?
            """;

        try (Connection connection = Database.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);

            try (ResultSet results = statement.executeQuery()) {
                if (results.next()) {
                    return new Product(
                        results.getInt("id"),
                        results.getString("name"),
                        results.getString("description"),
                        results.getInt("price")
                    );
                }
            }
        }

        return null;
    }
}