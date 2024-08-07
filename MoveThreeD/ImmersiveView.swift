//
//  ImmersiveView.swift
//  MoveThreeD
//
//  Created by Subash Shrestha on 07.08.24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct ImmersiveView: View {
    
    var body: some View {
        RealityView { content in
            if let skyBox  = createSkyBox(){
                content.add(skyBox)
            }
            if let earthModel =  buildModel( modelName:"Earth", scaleValue: 0.5){
                
                if let moonModel =   buildModel(modelName: "moon", scaleValue: 0.1){
                    earthModel.addChild(moonModel)
                    
                    let radians = 90.0 * Float.pi / 180.0
                    
                    moonModel.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
                    moonModel.orientation = simd_quatf(angle: radians, axis: SIMD3(x: 0, y: 1, z: 0))
                    moonModel.transform.scale *= 0.5
                    
                    content.add(moonModel)
                }
                content.add(earthModel)
            }
    
        }
//        .gesture(dragGesture)
    }
    
    var dragGesture: some Gesture{
        DragGesture()
            .targetedToAnyEntity()
            .onChanged{ value in
                value.entity.position =  value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
                
            }
            .onEnded{value in
                value.entity.components[PhysicsBodyComponent.self]?.mode =  .dynamic
                
                }
            
    }
    
    private func buildModel(modelName: String, scaleValue: Float)  -> Entity? {
        
        guard let modelEntity = try? Entity.load(named: modelName) else {
                print("Failed to load model named \(modelName)")
                return nil
            }
        if let modelIdentity =  modelEntity.children.first?.children.first{
            modelIdentity.position.y = 0.5
            
            modelIdentity.scale = [scaleValue, scaleValue, scaleValue]
            
            // Generate the collision effect with the base
            modelIdentity.generateCollisionShapes(recursive: true)
            modelIdentity.components.set(InputTargetComponent(allowedInputTypes: .all))
//            modelIdentity.components.set(ImageBasedLightComponent(source: .single(environment)))
//            modelIdentity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: modelIdentity))
//            modelIdentity.components.set(GroundingShadowComponent(castsShadow: true))
            
            modelIdentity.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
                massProperties: .default,
                material: .generate( staticFriction: 0.8, dynamicFriction:0.5, restitution: 0.1),
                mode: .dynamic
            ))
            
            modelIdentity.components[PhysicsMotionComponent.self] = .init()
        }
                 
        return modelEntity
        
         }
    
    
    private func createSkyBox() -> Entity? {
        let largeSphere = MeshResource.generateSphere(radius: 30)
        var skyboxMaterial =  UnlitMaterial()
        
        do{
            let texture =  try TextureResource.load(named: "starmap_2020_4k")
            skyboxMaterial.color = .init(texture: .init(texture))
        } catch {
            print("Failed to create skybox material: \(error)")
            return nil
        }
        
        let skyboxEntity = Entity()
        skyboxEntity.components.set(ModelComponent(mesh: largeSphere, materials: [skyboxMaterial]))
        
        skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
        
        return skyboxEntity
    }
    
}


#Preview(immersionStyle: .automatic) {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}

