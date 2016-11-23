package model.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import model.dao.UserDao;
import model.entity.User;
import model.service.UserService;

@Service
public class UserServiceImpl implements UserService{

    @Autowired
    private UserDao userDaoImpl;
    
    @Override
    public void addUser(User user) {
        userDaoImpl.addUser(user);
    }

    @Override
    public boolean checkUser(User user) {
        return userDaoImpl.checkUser(user);
    }

    @Override
    public List<User> queryUser() {
        return userDaoImpl.queryUser();
    }

    @Override
    public void updateUser() {
        userDaoImpl.updateUser();
    }

}
