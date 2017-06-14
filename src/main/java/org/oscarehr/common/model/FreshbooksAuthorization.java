package org.oscarehr.common.model;


import javax.persistence.*;

@Entity
@Table(name="freshbooksAuthorization")
public class FreshbooksAuthorization extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(name = "bearer_token", nullable = false)
    private String bearerToken;

    @Column(name = "expiry_time", nullable = false)
    private Integer expiryTime;

    @Column(name = "refresh_token", nullable = false)
    private String refreshToken;

    @Column(name = "client_id", nullable = false)
    private String client_id;

    @Column(name = "client_secret", nullable = false)
    private String client_secret;

    @Override
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getBearerToken() {
        return bearerToken;
    }

    public void setBearerToken(String bearerToken) {
        this.bearerToken = bearerToken;
    }

    public Integer getExpiryTime() {
        return expiryTime;
    }

    public void setExpiryTime(Integer expiryTime) {
        this.expiryTime = expiryTime;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {this.refreshToken = refreshToken;}

    public String getClientId() {return client_id;}

    public void setClientId(String client_id) {this.client_id = client_id;}

    public String getClientSecret() {return client_secret;}

    public void setClientSecret(String client_secret) {this.client_secret = client_secret;}
}
