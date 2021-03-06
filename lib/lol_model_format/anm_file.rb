require 'lol_model_format/base_types'

module LolModelFormat
    
    class AnmFile < BinData::Record
        endian :little
        
        uint32 :magic_1
        uint32 :magic_2
        uint32 :version
        uint32 :magic_3
        uint32 :number_of_bones , :value => lambda { bones.size }
        uint32 :number_of_frames ,
               #they should be the same but we just pick the first one here
               #TODO add validation for this
               :value => lambda { bones[0].frames.size } 
        uint32 :playback_fps
        
        class AnmBone < BinData::Record
            BONE_NAME_LENGTH = 32
            
            endian :little
            
            string :name, :length => BONE_NAME_LENGTH
            uint32 :flag
              
            class AnmFrame < BinData::Record
                endian :little
                
                quaternion :orientation_origin
                vector3 :position_origin
                
                def orientation            	
                    RQuat.new(orientation_origin.x.value, orientation_origin.y.value,
                        orientation_origin.z.value, orientation_origin.w.value)
                end
                
                def position
                    RVec3.new(position_origin.x.value, position_origin.y.value, position_origin.z.value)
                end
            end
                    
            array :frames, :type => :anm_frame, 
                  :read_until => lambda { index == number_of_frames - 1 }
        end
            
        array :bones, :type => :anm_bone, 
              :read_until => lambda { index == number_of_bones - 1 }
    end
end
