# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
  assert movies_table.hashes.size == Movie.all.count
end

Then /I should see "(.*)" before "(.*)"$/ do |e1, e2|
  assert page.body.index(e1) < page.body.index(e2)
end

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(",").each do |field|
    field = field.strip
    if uncheck == "un"
       step %Q{I uncheck "ratings_#{field}"}
       step %Q{the "ratings_#{field}" checkbox should not be checked}
    else
      step %Q{I check "ratings_#{field}"}
      step %Q{the "ratings_#{field}" checkbox should be checked}
    end
  end
end

Then /^I should see movies with the following ratings: (.*)/ do |rating_list|
  ratings = page.all("table#movies tbody tr td[2]").map! {|t| t.text}
  rating_list.split(",").each do |field|
    assert ratings.include?(field.strip)
  end
end

Then /^I should not see movies with the following ratings: (.*)/ do |rating_list|
  ratings = page.all("table#movies tbody tr td[2]").map! {|t| t.text}
  rating_list.split(",").each do |field|
    assert !ratings.include?(field.strip)
  end
end

When /^I check all ratings$/ do
  a = page.find_by_id("ratings_form").text.split.reverse
  a.pop
  a.each do |rating|
    check("ratings_#{rating}")
    assert page.find_by_id("ratings_#{rating}").checked?
  end
end

When /^I uncheck all ratings$/ do
  a = page.find_by_id("ratings_form").text.split.reverse
  a.pop
  a.each do |rating|
    uncheck("ratings_#{rating}")
    assert page.find_by_id("ratings_#{rating}").checked? == nil
  end
end

Then /^I should see all movies$/ do
  assert all("table#movies tr").count == Movie.all.count + 1
end

Then /^I should see no movies$/ do
  # >= because when no ratings are selected
  assert all("table#movies tr").count >= 1
end
