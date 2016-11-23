package controller.servlet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import model.entity.User;
import model.service.UserService;

@Controller
public class JumpServlet {

    @Autowired
    private UserService userService;

    @RequestMapping("jump")
    public String getAllUser(HttpServletRequest request) {
        List<User> list = new ArrayList<>();
        list = userService.queryUser();
        Collections.sort(list, new Comparator<User>() {
            public int compare(User o1, User o2) {
                int i = ((Integer) o1.getId()).compareTo((Integer) o2.getId());
                return i;
            }
        });
        request.setAttribute("resList", list);
        return "view";
    }

    @RequestMapping(value = "save", method = RequestMethod.POST)
    public String saveUser(User user) {
        userService.addUser(user);
        return "show";
    }

    @RequestMapping(value = "ajax", method = RequestMethod.POST)
    public @ResponseBody String login() {
        return "map";
    }

    @RequestMapping(value = "check", method = RequestMethod.POST)
    public String checkLogin(User user, HttpServletRequest request) {
        boolean res = userService.checkUser(user);
        if (res) {
            return "redirect:jump";
        }
        request.setAttribute("error", "用户名或密码错误!");
        return "../login";
    }
}
