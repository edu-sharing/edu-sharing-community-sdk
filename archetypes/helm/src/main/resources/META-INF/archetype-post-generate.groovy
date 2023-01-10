def run(File dir) {
    for (file in dir.listFiles()) {
        if (file.isDirectory()) {
            run(file);
        } else if (file.isFile() && file.name.endsWith(".sh")) {
            file.setExecutable(true, false)
        }
    }
}

run(dir = new File(new File(request.outputDirectory), request.artifactId));