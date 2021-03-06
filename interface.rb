require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'

class Interface 
  attr_reader :trains, :stations, :routes  
  def initialize
    @stations = []
    @trains = []
    @routes = []
    @index_train = 0
    @index_statuin = 0
    @index_route = 0

  end  
  def main_menu 
    puts" Введите цифру объекта, с которым вы хотите взаимодействовать:\n
    1 Станции\n
    2 Поезда\n
    3 Маршруты\n
    0 Выйти"

    point = gets.chomp.to_i

    case point 
    when 1
      station_menu
    when 2
      train_menu
    when 3 
      route_menu
    when 0
      exit 
    end           
  end
  private  
  def station_menu
    puts "    1 Создать станцию\n 
    2 Просматреть список станций\n 
    3 Просматреть список поездов на станции\n
    0 Назад в меню"
    point = gets.chomp.to_i
    case point 
    when 1 
      create_station
      station_menu
    when 2
      @stations.each { |station| puts station.name } 
      station_menu
    when 3
      index_of_station
      show_trains(@stations[@index_station])
      station_menu
    when 0
      main_menu
    end
  end 

  def train_menu
    puts "    1 Создать поезд\n 
          2 Добавить вагон к поезду\n
          3 Отцепить вагон от поезда\n
          4 Вывести список вагонов у поезда\n
          5 Занять место/объём у вагона\n
          6 Переместить поезд по маршруту\n 
          0 Назад в меню"

    point = gets.chomp.to_i  

    case point 
    when 1 
      create_train
      train_menu
    when 2
      index_of_train 
      add_wagon_to_train(@trains[@index_train])
      train_menu
    when 3 
      index_of_train  
      delete_wagon_to_train(@trains[@index_train])
      train_menu
    when 4 
      index_of_train
      show_wagons(@trains[@index_train]) 
      train_menu
    when 5 
      index_of_train
      index_of_wagon(@trains[@index_train])
      change_wagon(@trains[@index_train].wagons[@index_wagon])
      train_menu  
    when 6 
      index_of_train
      move_train(@trains[@index_train])
      train_menu   
    when 0
      main_menu
    end 
  end

  def route_menu 
    puts "    1 Создать маршрут\n
          2 Добавить станцию на маршрут\n
          3 Удалить станцию с маршрута\n
          4 Добавить поезд на маршрут\n
          0 Назад в меню"

    point = gets.chomp.to_i

    case point
    when 1
      create_route
      route_menu 
    when 2
      index_of_route
      index_of_station
      add_station_on_route(@routes[@index_route], @stations[@index_station]) 
      route_menu 
    when 3
      index_of_route
      index_of_station
      delete_station_on_route(@routes[@index_route], @stations[@index_station])
      route_menu 
    when 4
      index_of_route
      index_of_train
      set_route_to_train(@routes[@index_route], @trains[@index_train]) 
      route_menu 
    when 0
      main_menu  
    end 
  end    

  def show_wagons(train)
    i = 1
    train.each_wagon do |wagon| 
      puts "Вагон №#{i}:"
      puts " тип вагона: #{wagon.type}"
      if wagon.type == 'cargo' 
        puts "количество свободного объёма: #{wagon.free_volume}"
        puts "количество занятого объёма: #{wagon.taken_volume}"
      elsif wagon.type == 'passenger'
        puts "количество свободных мест: #{wagon.free_seats}"
        puts "количество занятых мест: #{wagon.taken_seats}"
      end  
      i += 1 
    end 
  end    

  def show_trains(station)
    station.each_train_on_staion {|train| puts "Поезд №#{train.number} Тип: #{train.type} Количество вагонов: #{train.wagons.size}"}
  end   



  def create_station
    puts 'Введите название станции'
    name_of_station = gets.chomp
    if not name_of_station.empty?  
      station = Station.new (name_of_station)
      @stations << station
    end
  end    

  def create_train 
    puts 'Введите номер XXX-XX или XXXXX поезда и тип (passenger или cargo)'
    number_of_train = gets.chomp
    type_of_train = gets.chomp 
    if type_of_train == 'cargo'
      train = CargoTrain.new(number_of_train) 
    elsif type_of_train == 'passenger'
      train = PassengerTrain.new(number_of_train)
    else 
      train = PassengerTrain.new(number_of_train, type_of_train)  
    end
      @trains << train
      puts "#{train} успешно создан"
  rescue RuntimeError
    puts 'Ошибка ввода данных'
    retry
  end 

  def index_of_wagon(train) 
    puts 'Выберите вагон по индексу'
    train.each_wagon { |wagon| puts "#{train.wagons.index(wagon)} <<< #{wagon}" }
    @index_wagon = gets.chomp.to_i
  end 

  def change_wagon(wagon)
    if wagon.type == 'passenger'
      wagon.take_seat
      puts 'Место успешно занято'
    elsif wagon.type == 'cargo'
      puts 'Сколько объёма вы хотите занять?'
      volume = gets.chomp.to_i
      wagon.take_volume(volume)
    end 
  end        

    
  def index_of_train 
    puts 'Выберите поезд по индексу'
    @trains.each { |train| puts "#{@trains.index(train)} <<< #{train.number}" }
    @index_train = gets.chomp.to_i
  end 

  def index_of_station 
    puts 'Выберите станцию по индексу'
    @stations.each { |station| puts "#{@stations.index(station)} <<< #{station.name}" }
    @index_station = gets.chomp.to_i
  end  
  
  def index_of_route 
    puts 'Выберите маршрут'
    @routes.each { |route| puts "#{@routes.index(route)} <<< #{route}" }
    @index_route = gets.chomp.to_i
  end  

  def create_route 
    puts 'Введите индекс начальной и конечной станции из списка:'
    index_of_station
    index_of_last_station = gets.chomp.to_i   
    route = Route.new(@stations[@index_station], @stations[index_of_last_station])
    @routes << route
  end  

  def add_station_on_route(route, station) 
    route.add_station(station) 
  end 

  def delete_station_on_route(route, station) 
    route.delete_station(station) 
  end 
  
  def set_route_to_train(route, train) 
    train.set_route(route)
  end
  
  def add_wagon_to_train(train)
    if train.type == 'cargo'
      puts 'Введите объём вагона'
      volume = gets.chomp.to_i
      wagon = CargoWagon.new(volume) 
      train.add_wagon(wagon)
    elsif train.type == 'passenger'
      puts 'Введите количество мест'
      seats = gets.chomp.to_i
      wagon = PassengerWagon.new(seats)
      train.add_wagon(wagon)
    end   
  end 

  def delete_wagon_to_train(train) 
    if train.wagons.length-1 !=0
      train.delete_wagon 
    end
  end  

  def move_train(train) 
    puts 'Вперёд(1) или Назад(2)'
    point = gets.chomp.to_i 
    if point == 1 
    train.go_to_next_station
    elsif point == 2
      train.go_to_previous_station 
    end 
  end 
end