build {
    sources = ["source.amazon-ebs.ssh-example"]

    provisioner "shell" {
        inline = ["echo Connected via SSH at '${build.Host}:${build.Port}'"]
    }

    provisioner "shell" {
        script = "setup.sh"
    }
}