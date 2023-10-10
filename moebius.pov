// +KFI0 +KFF240 +KC +C

// create a regular point light source
// light_source {
//   0*x                  // light's position (translated below)
//   color rgb <1,1,1>    // light's color
//   translate <-20, 40, -20>
// }
 
 // PoVRay 3.7 Scene File " ... .pov"
// author:  ...
// date:    ...
//------------------------------------------------------------------------
#version 3.7;
global_settings{ assumed_gamma 1.0 }
#default{ finish{ ambient 0.1 diffuse 0.9 }} 
//------------------------------------------------------------------------
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"

#declare SoftLight = 2;
#declare Softness = 10;
#declare SoftSize = 120;
#declare UseGlass = 1;
#declare SoftIntensity1 = 0.4;
#declare SoftIntensity2 = 1;
#declare DrawMoebius = 1;
#declare DrawTilePlane = 1;
#declare TexturedTiles = 1;

#declare TileSpacing = 1.05;
#declare TileWidth = 10;
#declare TileHeight = 5;
#declare TileRadius = 2;
#declare TileThickness = 1/2;
#declare FocalBlur = 1;

//------------------------------------------------------------------------ right handed Coordinate system z up 
#declare Camera_0 = camera {/*ultra_wide_angle*/ angle 55  // front view from x+
                            sky z
                            location  <10.0 , 0.0 , 1.0>
                            right    -x*image_width/image_height
                            look_at   <0.0 , 0.0 , 1.0>}
#declare Camera_1 = camera {/*ultra_wide_angle*/ angle 55  // diagonal view
                            sky z
                            right    -x*image_width/image_height
                            location  <20.0,-20.0, 24.0 >*2.0
                            look_at   <-1.0 , -5 , 3.6> 
                            #if (FocalBlur = 1)
                              aperture 0.7           // [0...N] larger is narrower depth of field (blurrier)
                              blur_samples 30        // number of rays per pixel for sampling
                              focal_point <0,-20, 2>    // point that is in focus <X,Y,Z>
                              confidence 0.98        // [0...<1] when to move on while sampling (smaller is less accurate)
                              variance 1/800         // [0...1] how precise to calculate (smaller is more accurate)                            
                            #end
                            }
#declare Camera_2 = camera {/*ultra_wide_angle*/ angle 55  //right side view from y-
                            sky z
                            location  <0.0 ,-10.0 , 1.0>
                            right    -x*image_width/image_height
                            look_at   <0.0 , 0.0 , 1.0>}
#declare Camera_3 = camera {/*ultra_wide_angle*/ angle 65   // top view from z- (x right y up )
                            sky z 
                            location  < 0,-0.001, 10>
                            right    -x*image_width/image_height
                            look_at   <0.0 , 0.0 , 1.0>}
camera{Camera_1}

#declare MyNBglass =
texture {
    finish {
        ambient 0.1
        diffuse 0.1
        reflection .25
        specular 1
        roughness .001
    }
}

//------------------------------------------------------------------------
// sun -------------------------------------------------------------------

#if (SoftLight = 0)
light_source{<1500,-2500, 2500> color LightBlue}
#end             

#if (SoftLight >= 1)
// An area light (creates soft shadows)
// WARNING: This special light can significantly slow down rendering times!
light_source {
  <0,0,0>             // light's position (translated below)
  color rgb SoftIntensity1       // light's color
  area_light
  <SoftSize, 0, 0> <0, 0, SoftSize> // lights spread out across this distance (x * z)
  Softness, Softness                // total number of lights in grid (4x*4z = 16 lights)
  adaptive 2          // 0,1,2,3...
  jitter              // adds random softening of light
  circular            // make the shape of the light circular
  orient              // orient light
  translate <1500, -2500, 2500>/5   // <x y z> position of light
}
#end
#if (SoftLight >= 2)
// An area light (creates soft shadows)
// WARNING: This special light can significantly slow down rendering times!
light_source {
  <0,0,0>             // light's position (translated below)
  color rgb SoftIntensity2       // light's color
  area_light
  <SoftSize, 0, 0> <0, 0, SoftSize> // lights spread out across this distance (x * z)
  Softness, Softness                // total number of lights in grid (4x*4z = 16 lights)
  adaptive 2          // 0,1,2,3...
  jitter              // adds random softening of light
  circular            // make the shape of the light circular
  orient              // orient light
  translate <1500, 2500, 2500>/5   // <x y z> position of light
}
#end
                       
//--------------------------------------------------------------------------
//---------------------------- objects in scene ----------------------------
//--------------------------------------------------------------------------
#macro MyColorGlass(RGB)
  //material {
    texture {
        MyNBglass
        pigment { color rgbf <RGB.x, RGB.y, RGB.z, 0.95> }
    }
    interior { I_Glass}
  //}
#end

#declare lightness_adjust = 1.1;
    
#declare MyRubyGlass = material {
    //texture { Ruby_Glass }
    //interior { I_Glass }
    //MyColorGlass(<0.8,0,0>))
    MyColorGlass(<0.9,0.3,0.3>)
}
#declare MyOrangeGlass = material {
    //texture { Orange_Glass }
    //interior { I_Glass }
    //MyColorGlass(<0.8, 0.4, 0>)
    MyColorGlass(<0.9, 0.5, 0.3>)
}
#declare MyYellowGlass = material {
    //texture { Yellow_Glass }
    //interior { I_Glass }
    //MyColorGlass(<0.8,0.7,0>)
    MyColorGlass(<0.9,0.8,0.3>)
}
#declare MyGreenGlass = material {
    //texture { Green_Glass }
    //interior { I_Glass }
    //MyColorGlass(<0.2,0.7,0>)
    MyColorGlass(<0.3,0.8,0.3>)
}
#declare MyDarkGreenGlass = material {
    //texture { Dark_Green_Glass }
    //interior { I_Glass }
    //MyColorGlass(<0.2,0.2,0.7>)
    MyColorGlass(<0.4,0.4,0.8>)
}

#declare MyMaterials = array[5] {
    MyRubyGlass,
    MyOrangeGlass,
    MyYellowGlass,
    MyGreenGlass,
    MyDarkGreenGlass
}

#declare MyTileMaterials = array[4] {
    T_Stone8,
    T_Stone15,
    T_Stone16,
    T_Stone17
}


// Simple Plastic Texture
#macro PlasticTexture(R,G,B)
material  {
    texture {
      pigment { color rgb <R, G, B> } 
      finish {
        ambient 0.2   // Ambient lighting
        diffuse 0.8   // Diffuse reflection
        specular 0.6  // Specular highlights
        reflection 0.05 // Slight reflection
        phong 0.3    // Phong shading for a plastic sheen
        phong_size 60 // Size of the phong highlights
      }
    }
}
#end

#declare MyRedPlastic = PlasticTexture(0.8,0,0);
#declare MyOrangePlastic = PlasticTexture(0.8,0.4,0);
#declare MyYellowPlastic = PlasticTexture(0.8,0.7,0);
#declare MyGreenPlastic = PlasticTexture(0.2,0.7,0);
#declare MyBluePlastic = PlasticTexture(0.2,0.2,0.7);
#declare MyWhitePlastic = PlasticTexture(0.9,0.9,0.9);
                             
#declare MyPlasticsSize = 5;
#declare MyPlastics = array[MyPlasticsSize] {
    MyRedPlastic,
    MyOrangePlastic,
    MyYellowPlastic,
    MyGreenPlastic,
    MyBluePlastic
}

#declare PI = 3.14159;

#macro Rod(Length, Radius, Materials, MaterialsSize, MaterialIndex)
merge {
    sphere { <-Length/2,0,0>, Radius 
    }
    cylinder { <-Length/2,0,0>, <Length/2,0,0>, Radius
    }
    sphere { <Length/2,0,0>, Radius
    }
    material { Materials[mod(MaterialIndex, MaterialsSize)] }
}
#end // of Rod macro         

#macro Moebius(RodCount, Radius, Twists, RodLength, RodRadius)
#local i = 0;
object {
    union {
        #while (i < RodCount)
            object {            
                Rod(RodLength, RodRadius, #if (UseGlass = 1) MyMaterials #else MyPlastics #end, 5, i)
                rotate <0,Twists * 180 * i / RodCount,0>
                translate <Radius, 0, 0>
                rotate <0, 0, 360 * i / RodCount >
            }                             
            #declare i = i + 1;
        #end   
    }
}
#end

#macro Tile(Width, Height, Radius, Thickness, Translate)
#local HalfWidth = Width/2;
#local HalfHeight = Height/2;
#local TopLeft = <-HalfWidth, HalfHeight, 0>;
#local TopRight = <HalfWidth, HalfHeight, 0>;
#local BottomLeft = <-HalfWidth, -HalfHeight, 0>;
#local BottomRight = <HalfWidth, -HalfHeight, 0>;
#local TopLeftInner = TopLeft + <Thickness/2, -Thickness/2, 0>;
#local TopRightInner = TopRight + <-Thickness/2, -Thickness/2, 0>;
#local BottomLeftInner = BottomLeft + <Thickness/2, Thickness/2, 0>;
#local BottomRightInner = BottomRight + <-Thickness/2, Thickness/2, 0>;

#local BoxWithHoles = 1;
#local CornerHolesRounding = 1;
#local TopAndBottomLobes = 1;
#local SpecialCorners = 1;

merge {
    #if (BoxWithHoles = 1)
    difference { // Box with Corner Holes
        merge {
             cylinder {BottomLeftInner, TopLeftInner, Thickness/2 } // Left
             cylinder {BottomRightInner, TopRightInner, Thickness/2 } // Right
             cylinder {BottomLeftInner, BottomRightInner, Thickness/2 } // Bottom
             cylinder {TopLeftInner, TopRightInner, Thickness/2 } // Top
             box { BottomLeftInner + <0,0, -Thickness/2>,
                   TopRightInner + <0, 0, Thickness/2> }
             
        }
        // rounded border
        cylinder { BottomLeft - z*Thickness, BottomLeft + z*Thickness, Radius + Thickness/2 }
        cylinder { TopLeft - z*Thickness, TopLeft + z*Thickness, Radius + Thickness/2}
        cylinder { BottomRight - z*Thickness, BottomRight + z*Thickness, Radius + Thickness/2}
        cylinder { TopRight - z*Thickness, TopRight + z*Thickness, Radius + Thickness/2}
    }
    #end
    #if (CornerHolesRounding = 1)
    intersection { // rounding of corner holes
        box { <-Width/2 + Thickness/2, -Height/2 + Thickness/2, -Thickness/2>, <Width/2 - Thickness/2, Height/2 - Thickness/2, Thickness/2> }
        merge {
            torus { Radius+Thickness/2, Thickness/2
                    rotate <90, 0, 0>
                    translate BottomLeft
            }
            torus { Radius+Thickness/2, Thickness/2 
                    rotate <90, 0, 0>
                    translate BottomRight
            }
            torus { Radius+Thickness/2, Thickness/2 
                    rotate <90, 0, 0>
                    translate TopLeft
            }
            torus { Radius+Thickness/2, Thickness/2 
                    rotate <90, 0, 0>
                    translate TopRight
            }        
       }
    }
    #end
    #if (TopAndBottomLobes = 1)
    // top and bottom lobes
    cylinder { <0, HalfHeight, -Thickness/2>, <0, HalfHeight, Thickness/2>, Radius - Thickness/2 }
    cylinder { <0, -HalfHeight, -Thickness/2>, <0, -HalfHeight, Thickness/2>, Radius - Thickness/2 }
    torus { Radius-Thickness/2, Thickness/2
            rotate <90, 0, 0>
            translate <0, HalfHeight, 0>
    }
    torus { Radius-Thickness/2, Thickness/2
            rotate <90, 0, 0>
            translate <0, -HalfHeight, 0>
    }
    #end
    #if (SpecialCorners = 1)
    intersection {
        difference {
            merge {
                torus { Radius+Thickness/2, Thickness/2
                    rotate <90, 0, 0>
                    translate BottomLeft
                }
                torus { Radius+Thickness/2, Thickness/2
                    rotate <90, 0, 0>
                    translate BottomRight
                }
                torus { Radius+Thickness/2, Thickness/2
                    rotate <90, 0, 0>
                    translate TopLeft
                }
                torus { Radius+Thickness/2, Thickness/2
                    rotate <90, 0, 0>
                    translate TopRight
                }
            }
            intersection { // rounding of corner holes
                box { <-Width/2 + Thickness/2, -Height/2 + Thickness/2, -Thickness/2>, <Width/2 - Thickness/2, Height/2 - Thickness/2, Thickness/2> }
                merge {
                    torus { Radius+Thickness/2, Thickness/2
                            rotate <90, 0, 0>
                            translate BottomLeft
                    }
                    torus { Radius+Thickness/2, Thickness/2 
                            rotate <90, 0, 0>
                            translate BottomRight
                    }
                    torus { Radius+Thickness/2, Thickness/2 
                            rotate <90, 0, 0>
                            translate TopLeft
                    }
                    torus { Radius+Thickness/2, Thickness/2 
                            rotate <90, 0, 0>
                            translate TopRight
                    }        
               }
            }                
            
        }
        merge {
            cylinder {BottomLeftInner, TopLeftInner, Thickness/2 } // Left
            cylinder {BottomLeftInner, BottomRightInner, Thickness/2 } // Bottom
            cylinder {BottomRightInner, TopRightInner, Thickness/2 } // Right
            cylinder {TopLeftInner, TopRightInner, Thickness/2 } // Top
        }
    }
    #end
    translate Translate
}
#end

#declare tileTextureSeed = seed(74134);
#declare tileTextureTransformSeed = seed (85134);

#macro TileRow(TileWidth, TileHeight, TileRadius, TileThickness, From, To, Xoffset, Yoffset)
  #local Row = From;
  #while (Row <= To)
    object {
        Tile(TileWidth, TileHeight, TileRadius, TileThickness, TileSpacing * <TileWidth * Row+Xoffset, Yoffset, 0>)
        #if (TexturedTiles = 1)
        material {
            texture {
                MyTileMaterials[floor(rand(tileTextureSeed)*4)]
                //T_Stone13
            }
            scale 3
            translate <rand(tileTextureTransformSeed)*100, rand(tileTextureTransformSeed)*100, rand(tileTextureTransformSeed)* 100>
            rotate <rand(tileTextureTransformSeed)*100, rand(tileTextureTransformSeed)*100, rand(tileTextureTransformSeed)* 100>
        }
        #end
    }
    #local Row = Row + 1;
  #end
#end

#macro TilePlane(TileWidth, TileHeight, TileRadius, TileThickness, FromX, ToX, FromY, ToY)
  #local Column = FromY;
  #while (Column <= ToY)
    TileRow(TileWidth, TileHeight, TileRadius, TileThickness, FromX, ToX, mod(Column,2)*TileWidth/2, Column*TileHeight)
    #local Column = Column + 1;
  #end
#end


#if (DrawMoebius = 1)                       
object {                       
    Moebius(140, 18, 4, 10, 1/2)
    translate <0,0,10>
    rotate <0, 0, 90 + 360*clock>
}
#end

//#declare TileWidth = 15;
//#declare TileHeight = 8;
//#declare TileRadius = 2;
//#declare TileThickness = 0.6;

#if (DrawTilePlane = 1)
union {
    TilePlane(TileWidth, TileHeight, TileRadius, TileThickness, -22, 22, -22, 22)
    material { MyWhitePlastic }
    rotate <0,0,15-180*clock>
}
#end
object {
    plane { <0,0,1>,0 }
    material { MyWhitePlastic }
}    
