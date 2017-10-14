# CatFeatures

Котовые фитчи.

## Что реализовано

- Генерация идентификаторов (IdGenerator)
- Настройки пользователя (UserOption)

## Предложение по работе с гемом, пока ветка master пригодна для использования в проектах на 4-х и 5-х рельсах

Сначала работаем с 4-ми рельсами:
- Разработать новую фитчу сделав новую ветку от мастера.
- Убедиться, что все тесты выполняются.
- Коммит

Потом работаем с 5-ми рельсами
```
git checkout AR-5.1
git rebase <Название ветки>
rvm use .
rspec scpe
```
И если тесты пройдены, то разработка окончена. Иначе - поправить где надо.

После ребейза мастера на ветку с фитчей для 4-х рельс надо выполнить
```
git checkout AR-5.1
git rebase master
git push -f
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cat-features'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cat-features

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
