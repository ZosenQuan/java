package test;

import java.util.List;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;

import dao.UserMapper;
import model.User;

@ContextConfiguration(locations = { "classpath:applicationContext.xml" })
public class TestOrm extends AbstractJUnit4SpringContextTests {

	@Autowired
	private UserMapper userMapper;
	@Autowired
	private HibernateTemplate hibernateTemplate;

	@Test
	public void test() {
		// ctx = new
		// ClassPathXmlApplicationContext("classpath:applicationContext.xml");
		// UserMapper userMapper = (UserMapper) ctx.getBean("userMapper");
		User u = new User();
		u.setUsername("quanzs");
		System.out.println(userMapper.selectUser(u));
		u.setUsername("wangyiheng");
		// u.setPassword("123456");
		// userMapper.insertUser(u);
		u.setPassword("222222");
		userMapper.updateUser(u);
		List<?> list = hibernateTemplate.find("from User");
		for (Object user : list) {
			System.out.println(user);
		}
		/*
		 * try { //factory = (SessionFactory) ctx.getBean("sessionFactory");
		 * Session session = sessionFactory.openSession(); Transaction tx =
		 * session.beginTransaction(); Query query = session.createQuery(
		 * "from User"); List<?> list = query.list(); for (Object user : list) {
		 * System.out.println(user); } tx.commit(); session.close(); } catch
		 * (HibernateException e) { e.printStackTrace(); }
		 */
	}
}
