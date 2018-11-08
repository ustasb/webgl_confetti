def docker_run(cmd)
  system("docker run -v #{Dir.pwd}:/opt/webgl_confetti webgl_confetti #{cmd}")
end

task :build_dist do
  system("rm -rf src/dist && mkdir src/dist")
  system("coffee --output src/dist --compile src/js")
end

task :build_public => [:build_dist] do
  system("rm -rf public && mkdir public")
  system("cp -r src/dist src/vendor src/index.html public")
end

task :docker_build_dist do
  docker_run("rake build_dist")
end

task :docker_build_dist_and_watch do
  system("fswatch -o src/js | xargs -n1 -I{} rake docker_build_dist")
end

task :docker_build_public do
  docker_run("rake build_public")
end
