package model.dao;

import java.util.List;

import model.entity.User;

public interface UserDao {
    public void addUser(User user);
    public List<User> queryUser();
    public void updateUser();
    public boolean checkUser(User user);
}
