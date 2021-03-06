require 'lol_model_format/skl_file'
require 'lol_model_format/skn_file'
require 'lol_model_format/anm_file'
require 'lol_model_format/ext/md2_file'

module LolModelFormat
    
    class LolModel
        
        include LolModelFormat::Ext

        #must be set when initialize, can't change for the time being
        attr_reader :skeleton_file, :skin_file, :animation_files
        
        def initialize(skl, skn, anms = {})
            @skeleton_file = skl
            @skin_file = skn
            @animation_files = anms
        end
        
        def get_md2_skin_coords(skinwidth, skinheight)
            skin_coords = []
            
            @skin_file.vertices.each do |v|
                coord = Md2File::SkinCoord.new
                coord.s = (skinwidth * v.tex_coords.x).to_i
                coord.t = (skinheight * v.tex_coords.y).to_i
                skin_coords	<< coord
            end
            
            skin_coords
        end
        
        def get_md2_trianles()
            triangles = []
            
            0.upto (@skin_file.indices.size / 3) do |i|
                
                #three vertex of a single triangle
                a = @skin_file.indices[3 * i]
                b = @skin_file.indices[3 * i + 1]
                c = @skin_file.indices[3 * i + 2]
                
                tri = Md2File::Triangle.new
                tri.index_xyz = [a, b, c]
                tri.index_st = [a, b, c]
                
                triangles << tri
            end
            
            triangles
        end
        
        def get_md2_frame(frame_name, vertices)
            puts frame_name
            
            frame = Md2File::Frame.new
            
            v_x_max = vertices.max_by { |v|  v.position.x.abs}.position.x
            v_y_max = vertices.max_by { |v|  v.position.y.abs}.position.y
            v_z_max = vertices.max_by { |v|  v.position.z.abs}.position.z			
            
            frame.scale.x = 2 * v_x_max / 256.0
            frame.scale.y = 2 * v_y_max / 256.0
            frame.scale.z = 2 * v_z_max / 256.0
            
            frame.translate.x = -v_x_max
            frame.translate.y = -v_y_max
            frame.translate.z = -v_z_max
            
            frame.name = frame_name			
            
            vertices.each do |v|
                
                vertex = Md2File::Vertex.new	
                x = ((v.position.x - frame.translate.x) / frame.scale.x).to_i
                y = ((v.position.y - frame.translate.y) / frame.scale.y).to_i
                z = ((v.position.z - frame.translate.z) / frame.scale.z).to_i
                
                #puts "[#{v.inspect}] => [#{x}, #{y}, #{z}]"
                            
                vertex.v = [x, y, z]
                
                normal = v.normal
                vertex.normal_index = 0
                vertex.normal_index = Md2File.get_anorms_index(
                                        normal.x, normal.y, normal.z)
                frame.verts << vertex		
            end
            
            frame
        end
        
        def get_md2_skl_trianles(count)
            triangles = []
            
            0.upto count do |i|
                
                #three vertex of a single triangle
                a = 4 * i
                b = 4 * i + 1
                c = 4 * i + 2
                
                tri = Md2File::Triangle.new
                tri.index_xyz = [a, b, c]
                tri.index_st = [a, b, c]
                
                triangles << tri
                
                #three vertex of a single triangle
                a = 4 * i
                b = 4 * i + 1
                c = 4 * i + 3
                
                tri = Md2File::Triangle.new
                tri.index_xyz = [a, b, c]
                tri.index_st = [a, b, c]
                
                triangles << tri
                
                #three vertex of a single triangle
                a = 4 * i
                b = 4 * i + 3
                c = 4 * i + 2
                
                tri = Md2File::Triangle.new
                tri.index_xyz = [a, b, c]
                tri.index_st = [a, b, c]
                
                triangles << tri
                
                #three vertex of a single triangle
                a = 4 * i + 3
                b = 4 * i + 1
                c = 4 * i + 2
                
                tri = Md2File::Triangle.new
                tri.index_xyz = [a, b, c]
                tri.index_st = [a, b, c]
                
                triangles << tri
            end
            
            triangles       	
        end
        
        def get_vertices_from_skl(skl, offset)
            vertices = []
            
            skl.bones.each do |i, b|
                
                next unless @skeleton_file.bone_ids.include? i        	 	
                
                unless b.root?
                    
                    #TODO
                    #vertex.normal.x = normal.x / total_weight
                    #vertex.normal.y = normal.y / total_weight
                    #vertex.normal.z = normal.z / total_weight
                    
                    #v.bone_index.each do |bi|
                    #    vertex.bone_index << bi
                    #end
                    
                    #v.weights.each do |w|
                    #    vertex.weights << w
                    #end
                    
                    #vertex.tex_coords.x = v.tex_coords.x
                    #vertex.tex_coords.y = v.tex_coords.y
                    
                    #top
                    vertex = SknFile::SknVertex.new
                    vertex.position.x = b.position.x
                    vertex.position.y = b.position.y
                    vertex.position.z = b.position.z
                    
                    #bottom three vertexes
                                
                    #parent
                    bp = b.parent
                    
                    vertex_parent = SknFile::SknVertex.new
                    vertex_parent.position.x = bp.position.x
                    vertex_parent.position.y = bp.position.y
                    vertex_parent.position.z = bp.position.z
                    
                    #slightly offset
                    vertex_helper = SknFile::SknVertex.new
                    vertex_helper.position.x = bp.position.x + offset
                    vertex_helper.position.y = bp.position.y - offset
                    vertex_helper.position.z = bp.position.z + offset
                    
                    #slightly offset 2
                    vertex_helper2 = SknFile::SknVertex.new
                    vertex_helper2.position.x = bp.position.x - offset
                    vertex_helper2.position.y = bp.position.y + offset
                    vertex_helper2.position.z = bp.position.z - offset        			
                    
                    vertices << vertex
                    vertices << vertex_parent
                    vertices << vertex_helper
                    vertices << vertex_helper2
                else
                    vertex = SknFile::SknVertex.new
                    vertex.position.x = b.position.x
                    vertex.position.y = b.position.y
                    vertex.position.z = b.position.z
                    
                    vertices << vertex
                    vertices << vertex
                    vertices << vertex
                    vertices << vertex 			
                end
            end
            
            vertices	        	
        end
        
        def get_skl_from_anm_frame(anm_file, frame_index)
            skeleton = Skeleton.new
            
            anm_file.bones.each_with_index do |bone, i|
                frame = bone.frames[frame_index]
                
                static_bone = static_skeleton.bones[i]
                
                b = Bone.new skeleton
                
                b.index = i
                b.name = bone.name
                b.parent_id = static_bone.parent_id
                b.scale = static_bone.scale
            
                b.orientation = frame.orientation
                b.position = frame.position	
                
                skeleton.bones[i] = b
            end
            
            skeleton.absolutify!
            skeleton
        end
        
        
        def to_md2_skl
            md2 = Md2File.new
            
            #TODO make skin size configurable
            md2.header.skinwidth = 512
            md2.header.skinheight = 512
            
            #Skin files are always external, so skin names aren't always useful
            md2.skin_names = []
            #OpenGL Commands aren't always useful too
            md2.gl_cmds = []	        
            
            #skin coord to UV-map the texturre/skin on the model
            md2.skin_coords = get_md2_skin_coords(md2.header.skinwidth, md2.header.skinheight)
            
            offset = 0.3
            
            #trianle that determines how all vertexes form faces TODO
            puts static_skeleton.bones.size
            
            static_vertices = get_vertices_from_skl(static_skeleton, offset)
            md2.triangles = get_md2_skl_trianles(static_vertices.size / 3)
            
            #add a frame to describe the static skeleton
            md2.frames << get_md2_frame("skl_static001", static_vertices)

            @animation_files.each do |name, anm_file|
                
                0.upto anm_file.number_of_frames - 1 do |frame_index|
                #1.upto 2 do |frame_index|
                    puts frame_index	
                                    
                        formated_frame_name = "skl_%s%03d" % [escape_md2_frame_name(name), frame_index + 1] 
                        
                        skeleton = get_skl_from_anm_frame(anm_file, frame_index)
                                        
                        md2.frames << get_md2_frame(formated_frame_name, get_vertices_from_skl(skeleton, offset))
                    end
            end

            md2
        end

        def to_md2
            md2 = Md2File.new
            
            #TODO make skin size configurable
            md2.header.skinwidth = 512
            md2.header.skinheight = 512
            
            #Skin files are always external, so skin names aren't always useful
            md2.skin_names = []
            #OpenGL Commands aren't always useful too
            md2.gl_cmds = []	        
            
            #skin coord to UV-map the texturre/skin on the model
            md2.skin_coords = get_md2_skin_coords(md2.header.skinwidth, md2.header.skinheight)
            
            #trianle that determines how all vertexes form faces
            md2.triangles = get_md2_trianles
            
            #add a frame to describe the static model
            md2.frames << get_md2_frame('static001', @skin_file.vertices)

            @animation_files.each do |name, anm_file|
                get_animated_vertice_frames(@skin_file.vertices, anm_file).each_with_index do |frame_vertices, i|
                    formated_frame_name = "%s%03d" % [escape_md2_frame_name(name), i + 1]
                    md2.frames << get_md2_frame(formated_frame_name, frame_vertices)
                end
            end

            md2
        end
        
        def escape_md2_frame_name(name)
            #          0 1 2 3 4 5 6 7 8 9
            table = %W[Z A B C D E F G H I]
            escaped_name = name.gsub(/\d/) do |digit|
                table[digit.to_i]
            end
            
            escaped_name
        end
        
        class Bone
            
            attr_accessor :skeleton
            attr_accessor :index, :name, :parent_id, :scale
            attr_accessor :orientation, :position, :transform
            attr_reader :reverse_transform
            
            def initialize(skl)        		
                @absolute = false   
                @skeleton = skl     		
                ##-1 reserved for root
                #@parent = -2
                #@scale = 0.0
                #@transform = RMtx4.new
                ##Quaternion
                #@orientation = RQuat.new
            end
            
            def root?
                @parent_id == -1 || @parent_id == 4294967295
            end
            
            def absolute?
                #root? ||                 
                @absolute
            end
            
            def parent
                return nil if root?
                @skeleton.bones[parent_id]
            end
            
            def absolutify!
                return if absolute?
                
                local_transform = RMtx4.new.setIdentity.rotationQuaternion(@orientation)
                local_transform *= RMtx4.new.setIdentity.translation(@position.x, @position.y, @position.z)
                #local_transform *= RMtx4.new.scaling(scale, scale, scale) 
                
                #/ 
                #local_transform.e30 = position.x# * (1.0 / scale)
                #local_transform.e31 = position.y# * (1.0 / scale)
                #local_transform.e32 = position.z# * (1.0 / scale)	
                                
                if root?
                    # No parent bone for root bones.
                    # So, just calculate directly.                                       
                    @transform = local_transform
                    @reverse_transform = @transform.getInverse
                    @orientation = @orientation
                else
                    #recursively up
                    parent.absolutify! unless parent.absolute? 
                    
                    # Append matrices for position transform A * B
                    # Append quaternions for rotation transform B * A
                    @transform = local_transform * parent.transform
                    @reverse_transform = @transform.getInverse
                    @orientation = parent.orientation * @orientation
                end
                
                #ensure that now it's absolute
                @absolute = true
            end
        end
        
        class Skeleton
            
            attr_accessor :bones
            
            def initialize        		
                @bones = {}
            end
            
            def absolutify!
                bones.each do |i, b|
                    b.absolutify!
                end
            end
        end
        
        def static_skeleton
            @static_skeleton ||= gen_static_skeleton_from_skl
        end
        
        def gen_static_skeleton_from_skl
            skeleton = Skeleton.new
            
            @skeleton_file.bones.each_with_index do |bone, i|
                
                b = Bone.new skeleton
                
                b.index = i
                b.name = bone.name
                b.parent_id = bone.parent_id
                b.scale = bone.scale

                b.orientation = bone.orientation
                b.position = bone.position	

                skeleton.bones[i] = b
            end
            
            skeleton.absolutify!
                        
            skeleton
        end

        
        def remap_bone_index(i)
            #return i
            
            bone_index = 0
            
            if @skeleton_file.version == 2
                if i < @skeleton_file.bone_ids.size     
                    bone_index = @skeleton_file.bone_ids[i]
                else
                    puts "ALERT: #{i} => 0"
                    bone_index = 0
                end	 
            else
                bone_index = i
            end
            
            bone_index
        end

        def get_animated_vertice_frames(vertices, anm_file)
            vertice_frames = []
            
            #0.upto anm_file.number_of_frames - 1 do |frame_index|
            0.upto 5 do |frame_index|
                puts frame_index
                
                frame_vertices =[]
                
                skeleton = get_skl_from_anm_frame(anm_file, frame_index)
                
                vertices.each do |v|
                    vertex = SknFile::SknVertex.new
                    
                    #// Transform the vertex information based on bones.
                    position = RVec3.new
                    normal = RVec3.new
                    total_weight = 0.0
                    
                    0.upto 3 do |i|
                        bone_index = remap_bone_index(v.bone_index[i])
                        
                        scale = static_skeleton.bones[bone_index].scale

                        
                        bone_transformer =  static_skeleton.bones[bone_index].reverse_transform
                        bone_transformer *= skeleton.bones[bone_index].transform
                        
                         #static_skeleton.bones[bone_index].reverse_transform * 
                        
                        
                        #bone_transformer = RMtx4.new.rotationY(0.314 * frame_index)
                        
                        v_postion = RVec3.new(v.position.x.value, v.position.y.value, v.position.z.value).transformCoord(bone_transformer)
                        
                        position += v.weights[i] * v_postion
                        
                        v_normal = RVec3.new(v.normal.x.value, v.normal.y.value, v.normal.z.value).transformNormal(bone_transformer)
                        
                        normal += v.weights[i] * v_normal
                        
                        total_weight += v.weights[i]
                    end
                    
                    vertex.position.x = position.x / total_weight
                    vertex.position.y = position.y / total_weight
                    vertex.position.z = position.z / total_weight
                    
                    vertex.normal.x = normal.x / total_weight
                    vertex.normal.y = normal.y / total_weight
                    vertex.normal.z = normal.z / total_weight
                    
                    v.bone_index.each do |bi|
                        vertex.bone_index << bi
                    end
                    
                    v.weights.each do |w|
                        vertex.weights << w
                    end
                    
                    vertex.tex_coords.x = v.tex_coords.x
                    vertex.tex_coords.y = v.tex_coords.y
                                   
                    frame_vertices << vertex

                end
            
                vertice_frames << frame_vertices
            end
            
            vertice_frames
        end
    end
end