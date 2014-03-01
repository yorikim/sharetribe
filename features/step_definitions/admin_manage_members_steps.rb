Then(/^I should see member count (\d+)$/) do |member_count|
  steps %Q{
    Then I should see "#{member_count}" within "#admin_members_count"
  }
end

Then(/^I should see list of users with the following details:$/) do |table|
  # table is a Cucumber::Ast::Table
  all("#admin_members_list tbody tr").each_with_index do |row, i|
    row.all("td").each_with_index do |cell, j|
      table.rows[i][j].should== cell.text
    end
  end
end

Then(/^I should see (\d+) users$/) do |user_count|
  all("#admin_members_list tbody tr").count.should == user_count.to_i
end

Then(/^the first user should be "(.*?)"$/) do |full_name|
  first_row = all("#admin_members_list tbody tr").first
  first_row.all("td").first.text.should == full_name
end
