//
//  ImmersiveView.swift
//  MoveThreeD
//
//  Created by Subash Shrestha on 07.08.24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            if let skyBox  = createSkyBox(){
                content.add(skyBox)
            }
            
            // Earth model
            
            if let earthModel  = try? await Entity(named: "Earth"),
               
               let earth =  earthModel.children.first?.children.first,
               let environment =  try? await EnvironmentResource(named: "ImageBasedLight"){
                     earth.position.y = 0.5
                     earth.position.x = 1
                
                     earth.scale = [0.5,0.5,0.5]
                     
                     // Generate the collision effect with the base
                     earth.generateCollisionShapes(recursive: true)
                     earth.components.set(InputTargetComponent(allowedInputTypes: .all))
                     earth.components.set(ImageBasedLightComponent(source: .single(environment)))
                     earth.components.set(ImageBasedLightReceiverComponent(imageBasedLight: earth))
                     earth.components.set(GroundingShadowComponent(castsShadow: true))
                     
                     earth.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
                         massProperties: .default,
                         material: .generate( staticFriction: 0.8, dynamicFriction:0.5, restitution: 0.1),
                         mode: .dynamic
                     ))
                     
                     earth.components[PhysicsMotionComponent.self] = .init()
                     
                     content.add(earthModel)
             }
    
        }
        .gesture(dragGesture)
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
      
        
    
    
    private func createSkyBox() -> Entity? {
        let largeSphere = MeshResource.generateSphere(radius: 30)
        var skyboxMaterial =  UnlitMaterial()
        
        do{
            let texture =  try TextureResource.load(named: "demo")
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
