package se.kth.webshop.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import se.kth.webshop.model.User;

public class UserDao {

    public User findByUsername(String username) throws SQLException {
        String sql = """
            SELECT id, username, password_hash
            FROM users
            WHERE username = ?
            """;

        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username);

            try (ResultSet results = statement.executeQuery()) {
                if (results.next()) {
                    return new User(
                        results.getInt("id"),
                        results.getString("username"),
                        results.getString("password_hash")
                    );
                }
            }
        }

        return null;
    }
    public User create(String username, String passwordHash) throws SQLException {
        String sql = """
            INSERT INTO users (username, password_hash)
            VALUES (?, ?)
            RETURNING id, username, password_hash
            """;

        try (Connection connection = Database.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.setString(2, passwordHash);

            try (ResultSet results = statement.executeQuery()) {
                if (!results.next()) {
                    throw new SQLException("User creation returned no result.");
                }

                return new User(
                    results.getInt("id"),
                    results.getString("username"),
                    results.getString("password_hash")
                );
            }
        }
    }
}