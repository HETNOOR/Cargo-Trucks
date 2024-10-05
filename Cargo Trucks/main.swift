//
//  main.swift
//  Cargo Trucks test
//
//  Created by Максим Герасимов on 01.10.2024.
//

import Foundation

// MARK: - Класс Vehicle (Транспортное средство)
class Vehicle {
    var make: String
    var model: String
    var year: Int
    var capacity: Int
    var currentLoad: Int
    var types: [CargoType]?
    var fuelTankCapacity: Double
    var fuelConsumptionPer100km: Double
    
    init(make: String, model: String, year: Int, capacity: Int, types: [CargoType]?, fuelTankCapacity: Double, fuelConsumptionPer100km: Double) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.fuelTankCapacity = fuelTankCapacity
        self.fuelConsumptionPer100km = fuelConsumptionPer100km
        self.currentLoad = 0
    }
    
    func canLoadCargo(_ cargo: Cargo) -> Bool {
        guard types?.contains(cargo.type) ?? true else {
            print("Невозможно загрузить, неподходящий тип груза: \(cargo.type.description)")
            return false
        }
        return true
    }
    
    func loadCargo(_ cargo: Cargo?) -> Bool {
        guard let cargo = cargo else {
            print("Груз не найден.")
            return false
        }
        

        if canLoadCargo(cargo) {
            guard currentLoad + cargo.weight <= capacity else {
                print("Невозможно загрузить груз, превышена грузоподъемность.")
                return false
            }
            currentLoad += cargo.weight
            print("Успешно загружен груз \(cargo.description) \(cargo.weight) кг на \(make) \(model). (\(currentLoad)|\(capacity))")
            return true
        }
        return false
    }
    
    func unloadCargo() {
        currentLoad = 0
        print("Машина \(make) \(model) разгружена.")
    }
    
    
    func maxTravelDistance() -> Int {
        return Int(Double(fuelTankCapacity) / (2 * fuelConsumptionPer100km) * 100)
    }
    
    func description() -> String {
        return "\(make) \(model), \(year) год. Грузоподъемность: \(capacity) кг. Текущая загрузка: \(currentLoad ) кг. Максимальная дистанция: \(maxTravelDistance()) км."
    }
    
    func copy() -> Vehicle {
        return Vehicle(make: make, model: model, year: year, capacity: capacity, types: types, fuelTankCapacity: fuelTankCapacity, fuelConsumptionPer100km: fuelConsumptionPer100km)
    }
}

// MARK: - Класс Truck (Грузовик)
class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerCurrentLoad: Int?
    var trailerTypes: [CargoType]?
    
    init(make: String, model: String, year: Int, capacity: Int, trailerAttached: Bool, trailerCapacity: Int? = nil, trailerTypes: [CargoType]? = nil, types: [CargoType]? = nil, fuelTankCapacity: Double, fuelConsumptionPer100km: Double) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerCurrentLoad = 0
        self.trailerTypes = trailerTypes
        super.init(make: make, model: model, year: year, capacity: capacity, types: types, fuelTankCapacity: fuelTankCapacity, fuelConsumptionPer100km: fuelConsumptionPer100km)
    }
    
  
    override func loadCargo(_ cargo: Cargo?) -> Bool {
        guard let cargo = cargo else {
            print("Груз не найден.")
            return false
        }
        
        var remainingWeight = cargo.weight
        
     
        let totalCapacity = capacity + (trailerCapacity ?? 0)
        let totalCurrentLoad = currentLoad + (trailerCurrentLoad ?? 0)
        
    
        guard totalCurrentLoad + cargo.weight <= totalCapacity else {
            print("Невозможно загрузить груз, превышена общая грузоподъемность.")
            return false
        }
        
      
        if canLoadCargo(cargo) {
            let availableCapacityInTruck = capacity - currentLoad
            if availableCapacityInTruck > 0 {
                let weightToLoadInTruck = min(remainingWeight, availableCapacityInTruck)
                currentLoad += weightToLoadInTruck
                remainingWeight -= weightToLoadInTruck
                print("Загружено \(weightToLoadInTruck) кг в кузов на \(make) \(model). Текущая загрузка кузова: \(currentLoad)|\(capacity) кг.")
            }
        }
        
      
        if remainingWeight > 0 && trailerAttached {
        
            if canLoadCargoInTrailer(cargo) {
                let availableCapacityInTrailer = trailerCapacity! - (trailerCurrentLoad ?? 0)
                if availableCapacityInTrailer > 0 {
                    let weightToLoadInTrailer = min(remainingWeight, availableCapacityInTrailer)
                    trailerCurrentLoad! += weightToLoadInTrailer
                    remainingWeight -= weightToLoadInTrailer
                    print("Загружено \(weightToLoadInTrailer) кг в прицеп. Текущая загрузка прицепа: \(trailerCurrentLoad!)|\(trailerCapacity!) кг.")
                } else {
                    print("Прицеп полностью загружен.")
                }
            }
        }
        
     
        if remainingWeight > 0 {
            print("Осталось незагружено \(remainingWeight) кг, не хватает места в транспортном средстве и прицепе.")
            return false
        }
        
        return true
    }
    
  
    func canLoadCargoInTrailer(_ cargo: Cargo) -> Bool {
        guard trailerTypes?.contains(cargo.type) ?? true else {
            print("Невозможно загрузить в прицеп, неподходящий тип груза: \(cargo.type.description)")
            return false
        }
        return true
    }
    
    override func unloadCargo() {
        super.unloadCargo()
        trailerCurrentLoad = 0
    }
    
    override func description() -> String {
        let capacityInfo = trailerAttached ? "\(capacity) кг + прицеп (\(trailerCapacity ?? 0) кг)" : "\(capacity) кг"
        return "\(make) \(model), \(year) год. Грузоподъемность: \(capacityInfo). Текущая загрузка: \(currentLoad) кг, в прицепе: \(trailerCurrentLoad ?? 0) кг."
    }
}


// MARK: - Структура Cargo (Груз)
struct Cargo: Equatable {
    var description: String
    var weight: Int
    var type: CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        guard weight >= 0 else {
            print("Невозможно создать груз \"\(description)\" с отрицательным весом.")
            return nil
        }
        self.description = description
        self.weight = weight
        self.type = type
    }
}

// MARK: - Перечисление CargoType (Тип груза)
enum CargoType: String {
    case fragile = "Хрупкий"
    case perishable = "Скоропортящийся"
    case bulk = "Сыпучий"
    
    var description: String {
        switch self {
        case .fragile:
            return "Хрупкий груз"
        case .perishable:
            return "Скоропортящийся груз"
        case .bulk:
            return "Сыпучий груз"
        }
    }
}

// MARK: - Класс Fleet (Автопарк)
class Fleet {
    var vehicles: [Vehicle] = []
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
    
    var totalCapacity: Int {
        vehicles.reduce(0) { $0 + $1.capacity + (($1 as? Truck)?.trailerCapacity ?? 0) }
    }
    
    var totalCurrentLoad: Int {
        vehicles.reduce(0) { $0 + $1.currentLoad + (($1 as? Truck)?.trailerCurrentLoad ?? 0) }
    }
    
    func description() {
        print("Текущий состав автопарка:")
        vehicles.forEach { print($0.description()) }
        print("Общая грузоподъемность автопарка: \(totalCapacity) кг.")
        print("Текущая загрузка автопарка: \(totalCurrentLoad) кг.")
    }
    
    func canGo(cargo: [Cargo?], path: Int) -> Bool {
        
        let tempFleet = Fleet()
        
        
        for vehicle in vehicles {
            tempFleet.addVehicle(vehicle.copy())
        }
        
        
        let totalCargoWeight = cargo.compactMap { $0 }.reduce(0) { $0 + $1.weight }
        
        
        guard totalCargoWeight <= tempFleet.totalCapacity else {
            print("Невозможно отправить груз, превышена общая грузоподъемность автопарка.")
            return false
        }
        
        
        var remainingCargo = cargo.compactMap { $0 }
        
        for vehicle in tempFleet.vehicles {
            for cargoItem in remainingCargo {
                if vehicle.loadCargo(cargoItem) {
                    if let index = remainingCargo.firstIndex(of: cargoItem) {
                        remainingCargo.remove(at: index)
                    }
                }
            }
        }
        
        
        if !remainingCargo.isEmpty {
            print("Остались незагруженные грузы: \(remainingCargo.map { $0.description })")
            return false
        }
        
        
        let totalFuelConsumption = tempFleet.vehicles.reduce(0) {
            $0 + (Double(path) / 100 * $1.fuelConsumptionPer100km) * 2
        }
        
        
        let totalFuelCapacity = tempFleet.vehicles.reduce(0) { $0 + $1.fuelTankCapacity }
        
        guard totalFuelConsumption <= totalFuelCapacity / 2 else {
            print("Недостаточно топлива для выполнения поездки.")
            return false
        }
        
        print("Груз успешно может быть отправлен на расстояние \(path) км.")
        return true
    }
    
    
}



// MARK: - Пример использования

let truckWithTrailer = Truck(
    make: "Volvo", model: "TR",
    year: 2019, capacity: 18000,
    trailerAttached: true, trailerCapacity: 5000, trailerTypes: [.perishable, .bulk] ,
    types: [.bulk],
    fuelTankCapacity: 500, fuelConsumptionPer100km: 30.0)

let truckWithoutTrailer = Truck(
    make: "Scania", model: "Zero",
    year: 2020, capacity: 15000,
    trailerAttached: false, trailerCapacity: nil, trailerTypes: nil,
    types: [.perishable],
    fuelTankCapacity: 400, fuelConsumptionPer100km: 28.0)

let van = Vehicle(
    make: "Mercedes", model: "Sprinter",
    year: 2018, capacity: 3500,
    types: [.fragile],
    fuelTankCapacity: 400, fuelConsumptionPer100km: 25.0)

let fleet = Fleet()

fleet.addVehicle(truckWithTrailer)
fleet.addVehicle(truckWithoutTrailer)
fleet.addVehicle(van)


let sand = Cargo(description: "Песок", weight: 8000, type: .bulk)
let milk = Cargo(description: "Молоко", weight: 3000, type: .perishable)
let glass = Cargo(description: "Стекло", weight: 1000, type: .fragile)
let stone = Cargo(description: "Щебень", weight: 3000, type: .bulk)
let cargo4 = Cargo(description: "Невесомое Перо", weight: -1, type: .fragile)

print("----- Загружаем грузы")

truckWithTrailer.loadCargo(sand) // успешно
truckWithTrailer.loadCargo(sand) // успешно
truckWithTrailer.loadCargo(stone)
print()
truckWithTrailer.loadCargo(milk) // успешно (нельзя в основной но можно в прицеп)
print()
truckWithoutTrailer.loadCargo(milk) // успешно
van.loadCargo(glass) // упешно

print("\n----- Загружаем груз, который не предназначен для этого типа транспорта")
print("  -- 1. груз не предназначен для этого типа транспорта")
truckWithoutTrailer.loadCargo(sand) // груз не предназначен для этого типа транспорта
print("  -- 2. груз не предназначен для этого типа прицепа")
truckWithTrailer.loadCargo(glass) //  груз не предназначен для этого типа прицепа
print("  -- 3. nil груз")
truckWithTrailer.loadCargo(cargo4) // nil груз
print("  -- 4.  перегруз")
truckWithTrailer.loadCargo(sand) // перегруз


print("\n----- Проверяем возможность поездки")


fleet.canGo(cargo: [milk, glass], path: 100)



print("\n-----")
fleet.description()

print("\n----- Разгружаем грузы")
truckWithTrailer.unloadCargo()
print("\n-----")
fleet.description()


