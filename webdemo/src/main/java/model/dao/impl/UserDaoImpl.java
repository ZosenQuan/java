package model.dao.impl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.stereotype.Service;

import model.dao.UserDao;
import model.entity.User;

@Service
public class UserDaoImpl implements UserDao {

    @Autowired
    private HibernateTemplate hibernateTemplate;

    @Override
    public void addUser(User user) {
        hibernateTemplate.save(user);
    }

    @Override
    public boolean checkUser(User user) {
        String hql = "from User where username='" + user.getUsername() + "' and password='" + user.getPassword() + "'";
        List<?> list = hibernateTemplate.find(hql);
        if (list == null || list.isEmpty()) {
            return false;
        }
        return true;
    }

    @Override
    public List<User> queryUser() {
        String hql = "from User";
        List<?> list = hibernateTemplate.find(hql);
        List<User> newList = new ArrayList<>();
        for (Object user : list) {
            User temp = (User) user;
            newList.add(temp);
        }
        return newList;
    }

    @Override
    public void updateUser() {

    }

}
