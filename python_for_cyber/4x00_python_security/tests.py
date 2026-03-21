#!/usr/bin/env python3
import unittest
from utils import validate_line, hash_password
from breach_check import check_policy


class TestSecurityTool(unittest.TestCase):

    def test_validate_line(self):
        self.assertTrue(validate_line("user@example.com:password123"))
        self.assertTrue(validate_line("test.user+1@mail.co.uk:MyPass!"))
        
        self.assertFalse(validate_line("invalidemail.com:password123"))
        self.assertFalse(validate_line("user@example.compassword123"))
        self.assertFalse(validate_line("user@example.com:"))
        self.assertFalse(validate_line(":password123"))

    def test_check_policy(self):
        self.assertEqual(check_policy("1234567"), 'WEAK')
        
        self.assertEqual(check_policy("password"), 'WEAK')
        self.assertEqual(check_policy("123456"), 'WEAK')
        
        self.assertEqual(check_policy("onlyletters"), 'WEAK')
        
        self.assertEqual(check_policy("123456789012"), 'COMPLIANT')
        
        self.assertEqual(check_policy("StrongPass123!"), 'COMPLIANT')

    def test_hash_password(self):
        password = "mypassword"
        salt = "MySuperSecretSalt"
        
        hash1 = hash_password(password, salt)
        hash2 = hash_password(password, salt)
        
        self.assertEqual(hash1, hash2)


if __name__ == '__main__':
    unittest.main()
