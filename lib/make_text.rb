words = ["apple", "orange", "banana", "grape", "peach"]

File.open("fruits.txt", 'w') do |f|
  5.times do
    f.puts Array.new(1000) { words[rand(5)] } * " "
  end
end
