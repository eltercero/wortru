Wortru
======

Wordpress import file to Ruby object using ROXML


Usage
-----

Initialize a wortru object passing the file path as an argument. After that, you'll be able to iterate thru the posts as Ruby objects (with help from ROXML).

```ruby
w = Wortru.new(File.join('doc', 'wp.xml'))

w.each do |item|
  ...
end
```
