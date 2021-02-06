void add_foo_tests () {

    Test.add_func ("/creation/normal_1", () => {
        var c = Cidr.from_string ("192.156.1.1/13");
        assert (c.to_string () == "192.156.1.1/13");
    });

    Test.add_func ("/creation/normal_2", () => {
        var c = Cidr.from_string ("10.1.1.0/16");
        assert (c.to_string () == "10.1.1.0/16");
    });

    Test.add_func ("/creation/normal_3", () => {
        var c = Cidr.from_string ("1.1.1.1/32");
        assert (c.to_string () == "1.1.1.1/32");
    });

    Test.add_func ("/creation/error_mask", () => {
        var c = Cidr.from_string ("192.256.1.1/113");
        assert (c == null);
    });

    Test.add_func ("/creation/error_ip", () => {
        var c = Cidr.from_string ("192.256.1.1/13");
        assert (c == null);
    });

    Test.add_func ("/subnet/hosts/1_network_same_object", () => {
        var cidr = Cidr.from_string ("192.168.231.1/24");
        var l = cidr.subnet_for_hosts (128);
        assert (l.length () == 1);
        assert (l.first ().data == cidr);
    });

    Test.add_func ("/subnet/hosts/1_network", () => {
        var cidr = Cidr.from_string ("192.168.231.1/24");
        var l = cidr.subnet_for_hosts (128);
        assert (l.length () == 1);
        assert (l.first ().data == cidr);
    });
}



void main (string[] args) {
    Test.init (ref args);
    add_foo_tests ();
    Test.run ();
}
