use core::array::ArrayTrait;

#[derive(Copy, Drop)]
struct Player {
    id: felt252,
    name: felt252,
    power: u256,
}

struct Plot {
    david: Player,
    goliath: Player,
    winner: Player,
}

fn burn(power: u256) { // burn power
}

fn get_king() -> Player {
    //logic to get king
    Player { id: 0, name: 'King', power: 1000, }
}

fn tribute(power: u256, mut king: Player) {
    king.power = king.power - (power * 1 / 100);
    burn(power * 4 / 100);
}

fn update_winner(mut player: Player, power: u256) {
    player.power = player.power + (power * 95 / 100);
}

fn absorb(plot: Plot) {
    if plot.david.id == plot.winner.id {
        update_winner(plot.david, plot.goliath.power);
        tribute(plot.goliath.power, get_king());
    } else {
        update_winner(plot.goliath, plot.david.power);
        tribute(plot.david.power, get_king());
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() { // assert(absirv(16) == 987, 'it works!');
    }
}
