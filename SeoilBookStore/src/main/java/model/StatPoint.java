package model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor @AllArgsConstructor
public class StatPoint {
    private String label; // 축 라벨: YYYY / YYYY-MM / YYYY-MM-DD
    private int count;    // 건수
}
