package cs.csg;

import java.io.Serializable;

public class Node implements Serializable {

    private static final long serialVersionUID = -7182958902860683483L;

    public Byte character;

    public Integer frequency;

    public Node left;

    public Node right;

    public Number value;

    Node(Byte character, Integer frequency) {
        this.character = character;
        this.frequency = frequency;
    }

}