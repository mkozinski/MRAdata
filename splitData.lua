lblDir="data/lbl"

ofile="dataSplit.lua"

local trainFiles={}
local testFiles ={}
for f in paths.iterfiles(lblDir) do
  fn=paths.concat(lblDir,f)
  if math.random() <0.25 then --test
    table.insert(testFiles, f)
  else --train
    table.insert(trainFiles,f)
  end
end
local of=io.open(ofile,"w")
of:write("trainFiles={\n")
for k,v in pairs(trainFiles) do
  of:write(string.format("\t\"%s\",\n",v))
end
of:write("}\n\ntestFiles={\n")
for k,v in pairs(testFiles) do
  of:write(string.format("\t\"%s\",\n",v))
end
of:write("}\n\ncutTrainFiles={\n")
for k,v in pairs(trainFiles) do
  of:write(string.format("\t\"%s\",\n",v.."_11"))
  of:write(string.format("\t\"%s\",\n",v.."_12"))
  of:write(string.format("\t\"%s\",\n",v.."_21"))
  of:write(string.format("\t\"%s\",\n",v.."_22"))
end
of:write("}\n")
of:close()
