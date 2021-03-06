#language: en
Feature: Main functionality
         In order to distribute files to other people
         As an authorised user of the system
         I want to be able to create, modify and delete files & folders
          
  Background:
    Given I am logged on        
    And I am not an admin user
    And the following users exist:
    | first_name | last_name | is_admin | can_hotlink | active | company | email               | password | password_confirmation |
    | Jim        | Wilson    | false    | false       | true   | bank    | test1@railsbox.com  | pass1    | pass1                 |
    | Harry      | Shaw      | false    | true        | true   | printer | test2@railsbox.com  | pass2    | pass2                 |
    | Robert     | Kent      | false    | false       | true   | supplier| test3@railsbox.com  | pass3    | pass3                 |
    
    And the following folders exist:
     | parent_id | name             | id    |
     |  nil      | folder1          | 1     |
     |  nil      | folder2          | 2     |
     |  2        | folder3          | 3     |  
     |  1        | folder4          | 4     |
     |  1        | folder5          | 5     |
     |  5        | folder6          | 6     |
    And the following files exist:
    | file        | folder_id | description | owner   | notes                                 |
    | test1.txt   | nil       | one         | jim     | someone elses private file            |
    | test2.txt   | nil       | two         | me      | my private file                       |
    | test3.txt   | 1         | three       | jim     | file in shared folder 1               |
    | test4.txt   | 1         | four        | me      | my file in shared folder 1            |
    | test5.txt   | 2         | five        | jim     | file in shared folder 2               |  
    | test6.txt   | 6         | six         | jim     | file in shared folder 6               |
    And I have the following user permissions:
    | folder_id  | read_perms | write_perms | assigned_by |
    | 1          | true       | true        | 1           |
    | 2          | true       | true        | 1           |
    | 3          | true       | true        | 1           |
    | 4          | true       | true        | 1           |
    | 5          | true       | true        | 1           |
    | 6          | true       | true        | 1           |
    When I visit folders
    
        
  Scenario: Download a file
      When I follow "test2.txt"    
      Then I should download "test2.txt"