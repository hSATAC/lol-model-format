$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__)) unless $LOAD_PATH.include?(File.expand_path('../../lib', __FILE__))
require File.expand_path('../../lib/lol_model_format', __FILE__)

include LolModelFormat
include LolModelFormat::Ext

model_name = "Cassiopeia"

skn_file_name = File.expand_path("../../spec/fixture/#{model_name}.skn", __FILE__)
File.open(skn_file_name, 'rb') do |io|
    @skn = SknFile.read(io)
end

skl_file_name = File.expand_path("../../spec/fixture/#{model_name}.skl", __FILE__)
File.open(skl_file_name, 'rb') do |io|
    @skl = SklFile.read(io)
end

anm_file_name = File.expand_path("../../spec/fixture/#{model_name}_Attack1.anm", __FILE__)
File.open(anm_file_name, 'rb') do |io|
    @anm = AnmFile.read(io)
end

# New a LolModel
@model = LolModel.new @skl, @skn, {"Attack1" => @anm}

# Convert to md2
md2 = @model.to_md2

@md2_file_name = File.expand_path("../../spec/fixture/#{model_name}.md2", __FILE__)
wio = File.open(@md2_file_name, 'wb')           
md2.write(wio)
wio.close 

# Convert to md2 file for skeleton
md2 = @model.to_md2_skl            
@md2_skl_file_name = File.expand_path("../../spec/fixture/#{model_name}_skl.md2", __FILE__)
wio = File.open(@md2_skl_file_name, 'wb')        
md2.write(wio)
wio.close  

