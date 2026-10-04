package se.kth.webshop.service;

import java.sql.SQLException;
import java.util.Arrays;

import se.kth.webshop.dao.UserDao;
import se.kth.webshop.model.User;
import se.kth.webshop.security.Passwords;

public class AuthService {
    private final UserDao userDao = new UserDao();

    public AuthService() {
    }

    public User authenticate(String username, String password) {
        if (username == null || username.isBlank()
                || username.length() > 50
                || password == null || password.isEmpty()
                || password.length() > 256) {
            return null;
        }

        char[] passwordCharacters = password.toCharArray();

        try {
            User user = userDao.findByUsername(username.trim());

            if (user != null
                    && Passwords.verify(
                        passwordCharacters, user.getPasswordHash())) {
                return user;
            }

            return null;
        } catch (SQLException e) {
            throw new IllegalStateException("Login database error.", e);
        } finally {
            Arrays.fill(passwordCharacters, '\0');
        }
    }
    public User register(String username, String password, String confirmation) {
        if (username == null) {
            throw new IllegalArgumentException("Invalid username.");
        }

        String cleanedUsername = username.trim();

        if (!cleanedUsername.matches("[A-Za-z0-9_]{3,50}")) {
            throw new IllegalArgumentException("Invalid username.");
        }

        if (password == null || password.length() < 15
                || password.length() > 256
                || !password.equals(confirmation)) {
            throw new IllegalArgumentException("Invalid password.");
        }

        char[] characters = password.toCharArray();

        try {
            String passwordHash = Passwords.hash(characters);
            return userDao.create(cleanedUsername, passwordHash);
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                throw new IllegalArgumentException("Username is unavailable.", e);
            }

            throw new IllegalStateException("Account creation failed.", e);
        } finally {
            Arrays.fill(characters, '\0');
        }
    }
}