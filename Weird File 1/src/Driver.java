import java.io.ObjectInputStream;
import java.io.FileInputStream;
import java.io.File;

import cs.csg.Node;
import java.util.BitSet;

public class Driver {

    public static final String FILE_NAME = "./bin1";

    public static void main(String[] args) {
        try {
            FileInputStream fi = new FileInputStream(new File(Driver.FILE_NAME));
            ObjectInputStream oi = new ObjectInputStream(fi);

            Node node = (Node) oi.readObject();

            BitSet bitSet = (BitSet) oi.readObject();

            System.out.println(bitSet);

            oi.close();
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}