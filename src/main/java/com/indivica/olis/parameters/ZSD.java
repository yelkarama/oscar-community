package com.indivica.olis.parameters;

public class ZSD implements Parameter {
    String firstName;
    String lastName;
    String relationship;

    public ZSD() {
    }

    public ZSD(String firstName, String lastName, String relationship) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.relationship = relationship;
    }

    @Override
    public String toOlisString() {
        return getQueryCode();
    }
    
    @Override
    public void setValue(Object value) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void setValue(Integer part, Object value) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void setValue(Integer part, Integer part2, Object value) {
        throw new UnsupportedOperationException();
    }

    @Override
    public String getQueryCode() {
        return "@ZSD.1^" + firstName + "~@ZSD.2^" + lastName + "~@ZSD.3^" + relationship;
    }
}
