//
//  ContentView.swift
//  CollectionViewTest
//
//  Created by Dave Durazzani on 7/24/23.
//

import SwiftUI
import Observation

//@Observable
//final class Car: Identifiable, Hashable, Equatable {
//
//    static func == (lhs: Car, rhs: Car) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    var id = UUID()
//    var year:Int = 0
//    var make:String = ""
//    var model:String = ""
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    init(year: Int, make: String, model: String) {
//        self.year = year
//        self.make = make
//        self.model = model
//    }
//    
//    static var cars:[Car] {
//        var tmp = [Car]()
//        for i in 0..<100 {
//            tmp.append(Car(year: i))
//        }
//        return tmp
//    }
//    
//}




final class Car:ObservableObject, Identifiable, Hashable, Equatable {

    static func == (lhs: Car, rhs: Car) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    @Published var year:Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(year: Int) {
        self.year = year
    }

    static var cars:[Car] {
        var tmp = [Car]()
        for i in 0..<100 {
            tmp.append(Car(year: i))
        }
        return tmp
    }
    
}






struct ContentView: View {
    
    @State var cars:[Car] = Car.cars
    @State var snapshot = NSDiffableDataSourceSnapshot<Int, Car>()
    
    
    var body: some View {
        VStack {
            TestCollectionView(snapshot: $snapshot)
        }
        .padding()
        .onAppear {
            setupSnapshot()
        }
    }
    
    func setupSnapshot() {
        guard snapshot.itemIdentifiers.count == 0 else { return }
        snapshot.appendSections([0])
        snapshot.appendItems(cars)
    }
    
}



struct TestCollectionView: UIViewRepresentable {
    
    @Binding var snapshot:NSDiffableDataSourceSnapshot<Int, Car>
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent:self)
    }
    
    func makeUIView(context: Context) -> some UICollectionView {
        context.coordinator.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
        context.coordinator.setupDatasource()
        return context.coordinator.collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.ds?.apply(snapshot)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
        let parent:TestCollectionView
        var collectionView:UICollectionView
        var ds:UICollectionViewDiffableDataSource<Int, Car>?
        
        init(parent: TestCollectionView) {
            self.parent = parent
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Coordinator.createLayout())
            self.collectionView.backgroundColor = .yellow
        }
        
        func setupDatasource() {
            let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Car> { cell, indexPath, car in
                
                let hostingConfiguration = UIHostingConfiguration {
                    CellView()
                        .environmentObject(car)
                }.margins(.all, 0)
                cell.contentConfiguration = hostingConfiguration
            }
            
            self.ds = UICollectionViewDiffableDataSource<Int, Car>(collectionView: collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        
        
        static func createLayout() -> UICollectionViewLayout {
            
            let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                
                let columns:Int = 2
                let inset: CGFloat = 10
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/CGFloat(columns)), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/CGFloat(columns)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                
                return section
                
            }
            
            return layout
            
        }
        
    }
    
}

struct CellView: View {
    
    @EnvironmentObject var car:Car
    
    var body: some View {
        Button {
            car.year = Int.random(in: 10...100)
            print("car.year: \(car.year)")
        } label: {
            Text("year: \(car.year)")
        }
        .buttonStyle(.borderless)
    }
    
}
