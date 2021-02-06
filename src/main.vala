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
           cidr.get_max_hosts ());
}

public static List<Cidr?> list_subnet_for_hosts (Cidr cidr, int max_ip) {
    var l = cidr.subnet_for_hosts (max_ip);
    print ("====== Found %u networks for %d hosts ======\n", l.length (), max_ip);
    foreach (var i in l) {
        print_cidr_info (i);
    }

    return l;
}

public static void list_subnet_for_networks (Cidr cidr, int max_network) {
    var l = cidr.subnet_for_networks (max_network);
    print ("====== Found %u networks for %u networks ======\n", l.length (), max_network);
    foreach (var i in l) {
        print_cidr_info (i);
    }
}

public static int main (string[] args) {

    var c2 = Cidr.from_string ("192.168.231.1/24");
    print_cidr_info (c2);
    
    /*
    list_subnet_for_hosts (c2, 31);
    list_subnet_for_hosts (c2, 32);
    */
    list_subnet_for_hosts (c2, 62);
    list_subnet_for_hosts (c2, 96);
    /*
    list_subnet_for_hosts (c2, 260);
    list_subnet_for_networks (c2, 3);
    list_subnet_for_networks (c2, 6);
    list_subnet_for_networks (c2, 15);
    list_subnet_for_networks (c2, 63);
    */
  
    print ("\nend\n");
    return 0;
    
}
