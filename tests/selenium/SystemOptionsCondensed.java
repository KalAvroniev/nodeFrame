package com.example.tests;

import java.util.regex.Pattern;
import java.util.concurrent.TimeUnit;
import org.junit.*;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;
import org.openqa.selenium.*;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Select;

public class SystemOptionsCondensed {
	private WebDriver driver;
	private String baseUrl;
	private StringBuffer verificationErrors = new StringBuffer();
	@Before
	public void setUp() throws Exception {
		driver = new FirefoxDriver();
		baseUrl = "http://localhost:8181/";
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
	}

	@Test
	public void testSystemOptionsCondensed() throws Exception {
		driver.get(baseUrl + "/home");
		// ERROR: Caught exception [ERROR: Unsupported command [waitForCondition]]
		// ERROR: Caught exception [ERROR: Unsupported command [getEval]]
		driver.findElement(By.cssSelector("span.ff-icon-before")).click();
		assertEquals(0, driver.findElements(By.xpath("//body[contains(@class, \"condensed\")]")).size());
		driver.findElement(By.id("toggle-condensed")).click();
		assertEquals(1, driver.findElements(By.xpath("//body[contains(@class, \"condensed\")]")).size());
		driver.findElement(By.id("toggle-condensed")).click();
		assertEquals(0, driver.findElements(By.xpath("//body[contains(@class, \"condensed\")]")).size());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
		String verificationErrorString = verificationErrors.toString();
		if (!"".equals(verificationErrorString)) {
			fail(verificationErrorString);
		}
	}

	private boolean isElementPresent(By by) {
		try {
			driver.findElement(by);
			return true;
		} catch (NoSuchElementException e) {
			return false;
		}
	}
}
