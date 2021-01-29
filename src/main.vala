public static void print_cidr_info (Cidr cidr) {
    if (cidr == null) {
        print ("-> Null");
        return;
    }  
    
    print ("** IP -> %s\n", cidr.to_string ());
    print ("   Net: %s, Brd: %s, Msk: %s (Max IP: %u)\n", 
           cidr.get_network_ip (), 
           cidr.get_broadcast_ip (),
           cidr.get_netmask (),
           cidr.get_max_ip ());
}

public static void print_cidr_list_networks (Cidr cidr, int max_ip) {
    var l = cidr.subnet_for_addresses (max_ip);
    print ("====== Found %u networks for %d addresses ======\n", l.length (), max_ip);
    foreach (var i in l) {
        print_cidr_info (i);
    }
}


public static int main (string[] args) {
    var c0 = Cidr.from_string ("192.256.1.1/13");
    print_cidr_info (c0);
    
    var c1 = Cidr.from_string ("0.0.0.1/113");
    print_cidr_info (c0);
    
    var c11 = Cidr.from_string ("10.1.1.0/16");
    print_cidr_info (c11);
    
    var c4 = Cidr.from_string("1.1.1.1/32");
    print_cidr_info (c4);

  
    var c2 = Cidr.from_string ("192.168.231.1/24");
    print_cidr_info (c2);
    
    print_cidr_list_networks (c2, 31);
    print_cidr_list_networks (c2, 32);
    print_cidr_list_networks (c2, 61);
    print_cidr_list_networks (c2, 96);
    print_cidr_list_networks (c2, 128);
    print_cidr_list_networks (c2, 260);

    return 0;
    
}
