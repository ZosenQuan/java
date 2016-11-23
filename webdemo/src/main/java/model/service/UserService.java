package model.service;

import java.util.List;

import model.entity.User;

public interface UserService {
    public void addUser(User user);
    public boolean checkUser(User user);
    public List<User> queryUser();
    public void updateUser();
}
