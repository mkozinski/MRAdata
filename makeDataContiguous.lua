lblDir="data/lbl/"

for f in paths.iterfiles(lblDir) do
  fn=paths.concat(lblDir,f)
  a=torch.load(fn)
  torch.save(fn,a:contiguous())
end

