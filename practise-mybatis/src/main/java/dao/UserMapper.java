package dao;  
  
import model.User;  
  
public interface UserMapper {  
    public User selectUser(User user);  
    public void insertUser(User user);  
    public void updateUser(User user);  
    public void deleteUser(int userId);  
}