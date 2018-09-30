np4th=require "npy4th"
dir = "npy_img"
odir = "lua_img"
os.execute("mkdir "..odir)

for f in paths.iterfiles(dir) do
  fn=paths.concat(dir,f)
  a=np4th.loadnpy(fn)
  torch.save(paths.concat(odir,f:sub(1,-5)),a:reshape(1,a:size(1),a:size(2),a:size(3)))
end
