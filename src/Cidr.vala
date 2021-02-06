using GLib;

public class Cidr {
    /*
     *  We don't use the human friendly notation.
     * 
     * IP address AA.BB.CC.DD (XX is in hexadecimal) is equal to
     * the uint32 0xAABBCCDD. Let's say it's the binary version.
     */ 
    uint32 _binary_ip;
    uint32 _binary_netmask = ~0;



    // Create a new Cdir Object:
    public Cidr (uint32 binary_ip, uint32 binary_mask) {
        _binary_ip = binary_ip;
        _binary_netmask = binary_mask;
    }
    
    public string binary_ip_to_string (uint32 ip) {
        uint8 block1, block2, block3, block4;

        block1 = (uint8) ((ip & 0xFF000000) >> 24);
        block2 = (uint8) ((ip & 0x00FF0000) >> 16);
        block3 = (uint8) ((ip & 0x0000FF00) >> 8);
        block4 = (uint8)  (ip & 0x000000FF);
        
        return "%u.%u.%u.%u".printf (block1, block2, block3, block4);
    }
    
    
    public string to_string () {
        return "%s/%u". printf (binary_ip_to_string (_binary_ip), get_cidr_netmask ());
    }
    
    
    public string get_network_ip () {
        return binary_ip_to_string (_binary_ip & _binary_netmask);
    }
    
    
    public string get_broadcast_ip () {
        return binary_ip_to_string (_binary_ip | ~_binary_netmask);
    }
    
    
    public string get_netmask () {
        return binary_ip_to_string (_binary_netmask);
    }
    
    public List<Cidr> subnet_for_hosts (uint32 max_ip) {
        List<Cidr?> networks_list = new List<Cidr> ();
        
        //print ("For %u ip addresses\n", max_ip);
        
        if (max_ip >= get_max_hosts ()) {
            warning ("Too many hosts requested!");
            return networks_list;
        }
        
        uint32 binary_hosts_mask = 0;
        uint8 hosts_bits = 0;
        while (hosts_bits < get_cidr_netmask ()) {
            if ((1 << hosts_bits) > max_ip) {
                break;
            }
            
            binary_hosts_mask |= (1 << hosts_bits);
            hosts_bits++;
        }

        // For /24 network (0xFFFFFF00) and 30 hosts (5 bits or 0x000001F)
        // _binary_mask | binary_hosts_mask = 0xFFFFFF1F
        // ~(_binary_mask | binary_hosts_mask) = 0x00000E0
        // 0x00000E0 >> 5 = 7  
        // 
        // As we count from 0x000 to 0x111, there are 7 + 1 possiblities.
        uint32 networks_count = (~(_binary_netmask | binary_hosts_mask) >> hosts_bits) + 1;
        uint32 network_mask = _binary_netmask | ~binary_hosts_mask;
        
        //print (" - bits for hosts : %d\n", hosts_bits);
        //print (" - network mask   : %X\n", network_mask);
        //print (" - nbr of networks: %u\n", networks_count);

        // One network found. It's the current Cidr object.
        if (networks_count == 1) {
            networks_list.append(this);
            return networks_list;
        }

        for (var network = 0; network < networks_count; network++) {
            uint32 tmp_network_ip = (_binary_ip & _binary_netmask) | (network << hosts_bits);  
            //uint32 tmp_broadcast = tmp_network_ip | ~network_mask;
            /*        
            print (" net %d - %s/%s (%X) - Broad: %s\n", 
                  network, 
                  binary_ip_to_string (tmp_network_ip),
                  binary_ip_to_string (network_mask),
                  network_mask, 
                  binary_ip_to_string (tmp_broadcast));
            */
            networks_list.append(new Cidr (tmp_network_ip, network_mask));
        }
        
        return networks_list;
    }
    
    public List<Cidr> subnet_for_networks (uint32 max_networks) {
        uint32 network_bits = 0;
        uint32 network_mask = _binary_netmask;
        uint32 network_length = get_cidr_netmask ();
        List<Cidr> network_list = new List<Cidr> ();
        
        for (network_bits = 0; (1 << network_bits) < max_networks; network_bits++) {
            network_mask |= (1 << (31 - network_length));
            network_length++;
        }
        
        uint32 max_hosts = ~(network_mask) - 1;
        if (max_hosts == 0) {
            return network_list;
        }
        
        uint32 effective_max_network = (1 << network_bits);

        /*
        print ("bits     : %u for %u networks\n", network_bits, max_networks);
        print ("max ntwrk: %u\n", effective_max_network);
        print ("Mask     : %X\n" , network_mask);
        print ("Mx hosts : %u\n" , max_hosts);
        print ("mask lng : %u\n" , network_length);
        */
        
        for (uint32 i=0; i < effective_max_network; i++) {
            uint32 temp_network_ip = (_binary_ip & network_mask) | (i << (32 - network_length));
            /*
            print ("** Network: %s/%s) (%X)\n", 
                   binary_ip_to_string (temp_network_ip),
                   binary_ip_to_string(network_mask),
                    temp_network_ip);
            */
            network_list.append(new Cidr (temp_network_ip, network_mask));
        }

        return network_list;
    }
    
    public uint32 get_max_hosts () {
        if (_binary_netmask == uint32.MAX) {
            return 1;
        }
        
        return ~(_binary_netmask) - 1;
    }
    
    
    public uint8 get_cidr_netmask () {
        uint8 i;   
        for (i = 0; i < 32; i++) {
            if (_binary_netmask << i == 0) {
                break; 
            }
        } 

        return i;
    }
    
    delegate bool ValidateFunc (string str, out uint val);
    
    public static Cidr? from_string (string str) {
        MatchInfo match_info;
        uint block1 = 0, block2 = 0, block3 = 0, block4 = 0;
        
        try {
            Regex regex = new Regex ("(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d+)");
            regex.match (str, 0, out match_info);
        } catch (RegexError e) {
		    print ("Error %s\n", e.message);
		    return null;
	    }
	    
	    if (match_info.get_match_count () != 6) {
	        warning ("Cannot find match for CIDR format: IPv4/mask");
	        return null;
	    }
	    
	    ValidateFunc validate_block = (str, out val) => {
	        val = uint.parse (str);
            return (val >= 0 && val <= 255);
	    };

	    bool ip_valid = validate_block (match_info.fetch (1), out block1)
	                 && validate_block (match_info.fetch (2), out block2)
	                 && validate_block (match_info.fetch (3), out block3)
	                 && validate_block (match_info.fetch (4), out block4);
	    
	    if (! ip_valid) {
	        print ("IP '%s' is not valid.\n", str);
	        return null;
	    } 
	        
	    // TODO: try_parse is a better option
	    uint mask = uint.parse (match_info.fetch (5));
	    if (mask < 0 || mask > 32) {
	        print ("Mask is not valid for %s\n", str);
	        return null;
	    }
	    
	    uint32 binary_ip = (block1 << 24) + (block2 << 16) + (block3 << 8) + block4;

        /* Convert a CIDR mask in a binary form.
         *  For a mask of /24 (0xFFFFFF00):
         *    (1 << (32 - 24) = 0x00000100
         *   ((1 << 8) - 1)   = 0x000000FF
         *  ~((1 << 8) - 1)   = 0xFFFFFF00
         */  
        uint32 binary_mask = ~((1 << (32 - mask)) - 1);
        
        return new Cidr(binary_ip, binary_mask);
    }
}
